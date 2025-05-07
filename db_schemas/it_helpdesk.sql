-- Roles Table: Defines user roles
Roles (
    role_id INTEGER PRIMARY KEY,
    role_name TEXT NOT NULL UNIQUE  -- e.g., 'End-User', 'Agent', 'Admin'
);

-- Users Table: Stores user information
Users (
    user_id INTEGER PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL, -- Store hashed passwords only!
    full_name TEXT,
    role_id INTEGER NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1, -- Boolean (1=Active, 0=Inactive)
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES Roles(role_id) ON DELETE RESTRICT
);

-- Teams Table: Defines support teams
Teams (
    team_id INTEGER PRIMARY KEY,
    team_name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- User_Teams Table: Maps Agents to Teams (Many-to-Many)
User_Teams (
    user_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    PRIMARY KEY (user_id, team_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id) ON DELETE CASCADE
);

-- Ticket Statuses Table: Lookup for ticket statuses
Ticket_Statuses (
    status_id INTEGER PRIMARY KEY,
    status_name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_closing_status INTEGER NOT NULL DEFAULT 0 -- Boolean (1=Resolved/Closed states)
);

-- Ticket Priorities Table: Lookup for ticket priorities
Ticket_Priorities (
    priority_id INTEGER PRIMARY KEY,
    priority_name TEXT NOT NULL UNIQUE,
    sort_order INTEGER UNIQUE -- For ordering priorities (e.g., 1=Urgent, 4=Low)
);

-- Ticket Categories Table: Lookup for ticket categories
Ticket_Categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE,
    description TEXT
);

-- SLA Policies Table: Defines Service Level Agreements
SLA_Policies (
    sla_policy_id INTEGER PRIMARY KEY,
    policy_name TEXT NOT NULL UNIQUE,
    response_time_minutes INTEGER, -- Time to first response (in minutes)
    resolution_time_minutes INTEGER, -- Time to resolve (in minutes)
    description TEXT
    -- Note: More complex SLA logic (business hours, priority links) adds significant complexity.
    -- This is a simplified version. Could link to Priority/Category here if needed.
);

-- Tickets Table: Core table for helpdesk requests
Tickets (
    ticket_id INTEGER PRIMARY KEY,
    subject TEXT NOT NULL,
    description TEXT,
    status_id INTEGER NOT NULL,
    priority_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    requester_id INTEGER NOT NULL, -- User who submitted the ticket
    assigned_agent_id INTEGER, -- User (Agent) assigned to the ticket
    assigned_team_id INTEGER, -- Team assigned to the ticket
    sla_policy_id INTEGER,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_by_date TEXT, -- Could be calculated based on SLA and created_at
    resolved_at TEXT, -- Timestamp when resolved
    closed_at TEXT, -- Timestamp when closed
    last_updated_by_user_id INTEGER, -- User who last updated the ticket
    FOREIGN KEY (status_id) REFERENCES Ticket_Statuses(status_id) ON DELETE RESTRICT,
    FOREIGN KEY (priority_id) REFERENCES Ticket_Priorities(priority_id) ON DELETE RESTRICT,
    FOREIGN KEY (category_id) REFERENCES Ticket_Categories(category_id) ON DELETE RESTRICT,
    FOREIGN KEY (requester_id) REFERENCES Users(user_id) ON DELETE CASCADE, -- If requester deleted, cascade delete their tickets? Or SET NULL? Cascade is simpler here.
    FOREIGN KEY (assigned_agent_id) REFERENCES Users(user_id) ON DELETE SET NULL, -- If agent deleted, unassign ticket
    FOREIGN KEY (assigned_team_id) REFERENCES Teams(team_id) ON DELETE SET NULL, -- If team deleted, unassign ticket
    FOREIGN KEY (sla_policy_id) REFERENCES SLA_Policies(sla_policy_id) ON DELETE SET NULL,
    FOREIGN KEY (last_updated_by_user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Ticket Comments Table: Stores public replies and internal notes
Ticket_Comments (
    comment_id INTEGER PRIMARY KEY,
    ticket_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL, -- Author of the comment
    comment_text TEXT NOT NULL,
    is_internal INTEGER NOT NULL DEFAULT 0, -- Boolean (0=Public, 1=Internal Note)
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id) ON DELETE CASCADE, -- If ticket deleted, delete comments
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE -- If user deleted, delete their comments? Or SET NULL? Cascade is simpler.
);

-- Attachments Table: Stores file attachment metadata
Attachments (
    attachment_id INTEGER PRIMARY KEY,
    ticket_id INTEGER, -- Optional: Link directly to ticket
    comment_id INTEGER, -- Optional: Link to a specific comment
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL UNIQUE, -- Path on the server where the file is stored
    mime_type TEXT NOT NULL,
    file_size_bytes INTEGER NOT NULL,
    uploaded_by_user_id INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (comment_id) REFERENCES Ticket_Comments(comment_id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by_user_id) REFERENCES Users(user_id) ON DELETE SET NULL, -- Keep attachment record even if uploader deleted
    CHECK (ticket_id IS NOT NULL OR comment_id IS NOT NULL) -- Must be linked to either a ticket or a comment
);


-- KB Categories Table: Categories for Knowledge Base articles
KB_Categories (
    kb_category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INTEGER, -- For hierarchical categories (optional)
    FOREIGN KEY (parent_category_id) REFERENCES KB_Categories(kb_category_id) ON DELETE SET NULL
);

-- KB Articles Table: Stores knowledge base content
KB_Articles (
    article_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL, -- Consider storing HTML or Markdown
    kb_category_id INTEGER,
    author_id INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'Draft', -- 'Draft', 'Published', 'Archived'
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    published_at TEXT, -- Timestamp when first published
    last_updated_by_user_id INTEGER,
    helpful_votes INTEGER DEFAULT 0,
    not_helpful_votes INTEGER DEFAULT 0,
    FOREIGN KEY (kb_category_id) REFERENCES KB_Categories(kb_category_id) ON DELETE SET NULL,
    FOREIGN KEY (author_id) REFERENCES Users(user_id) ON DELETE RESTRICT, -- Don't delete article if author deleted? Or SET NULL? RESTRICT seems safer.
    FOREIGN KEY (last_updated_by_user_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    CHECK (status IN ('Draft', 'Published', 'Archived'))
);

-- KB Tags Table: Tags for KB articles
KB_Tags (
    tag_id INTEGER PRIMARY KEY,
    tag_name TEXT NOT NULL UNIQUE
);

-- Article_Tags Table: Maps Tags to Articles (Many-to-Many)
Article_Tags (
    article_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (article_id, tag_id),
    FOREIGN KEY (article_id) REFERENCES KB_Articles(article_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES KB_Tags(tag_id) ON DELETE CASCADE
);

-- Time Entries Table: Tracks time spent by agents on tickets
Time_Entries (
    entry_id INTEGER PRIMARY KEY,
    ticket_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL, -- Agent who logged the time
    start_time TEXT, -- Optional, could just be duration
    end_time TEXT,   -- Optional
    duration_minutes INTEGER NOT NULL, -- Duration spent in minutes
    notes TEXT,
    logged_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE -- If agent deleted, remove their time entries
);

-- Audit Logs Table: Records significant system events
Audit_Logs (
    log_id INTEGER PRIMARY KEY,
    timestamp TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER, -- User performing the action (NULL for system actions)
    action TEXT NOT NULL, -- e.g., 'USER_LOGIN', 'TICKET_CREATE', 'ARTICLE_PUBLISH', 'CONFIG_CHANGE'
    target_entity TEXT, -- e.g., 'Ticket', 'User', 'KB_Article'
    target_id INTEGER, -- e.g., ticket_id, user_id
    details TEXT, -- JSON or plain text details about the change
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL -- Keep log even if user deleted
);