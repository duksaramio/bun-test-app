-- I. Core & Common Tables
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    first_name TEXT,
    last_name TEXT,
    department TEXT,
    job_title TEXT,
    is_active INTEGER DEFAULT 1,
    is_sso_user INTEGER DEFAULT 0,
    last_login_at TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_roles (
    user_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

CREATE TABLE permissions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE role_permissions (
    role_id INTEGER NOT NULL,
    permission_id INTEGER NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
);

CREATE TABLE user_settings (
    user_id INTEGER PRIMARY KEY,
    language_preference TEXT DEFAULT 'en-US',
    timezone_preference TEXT DEFAULT 'UTC',
    email_notifications_enabled INTEGER DEFAULT 1,
    in_app_notifications_enabled INTEGER DEFAULT 1,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE system_announcements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    created_by_user_id INTEGER,
    start_date TEXT,
    end_date TEXT,
    is_active INTEGER DEFAULT 1,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE audit_trails (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    action_performed TEXT NOT NULL,
    entity_type TEXT,
    entity_id INTEGER,
    change_details TEXT,
    ip_address TEXT,
    timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE delegations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    delegator_user_id INTEGER NOT NULL,
    delegatee_user_id INTEGER NOT NULL,
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    reason TEXT,
    is_active INTEGER DEFAULT 1,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (delegator_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (delegatee_user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE controlled_list_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE controlled_list_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    list_type_id INTEGER NOT NULL,
    item_value TEXT NOT NULL,
    item_description TEXT,
    is_active INTEGER DEFAULT 1,
    sort_order INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (list_type_id, item_value),
    FOREIGN KEY (list_type_id) REFERENCES controlled_list_types(id) ON DELETE CASCADE
);

-- II. Document Management Module Tables
CREATE TABLE documents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    document_number TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    document_type_item_id INTEGER NOT NULL,
    owner_user_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (document_type_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE document_versions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    document_id INTEGER NOT NULL,
    version_number TEXT NOT NULL,
    status_item_id INTEGER NOT NULL,
    effective_date TEXT,
    obsolete_date TEXT,
    change_summary TEXT,
    file_name TEXT,
    file_path TEXT,
    file_mime_type TEXT,
    uploaded_by_user_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (document_id, version_number),
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
    FOREIGN KEY (status_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (uploaded_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE document_review_workflows (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    document_version_id INTEGER NOT NULL,
    workflow_type TEXT NOT NULL DEFAULT 'Sequential',
    status TEXT NOT NULL DEFAULT 'Pending',
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (document_version_id) REFERENCES document_versions(id) ON DELETE CASCADE
);

CREATE TABLE document_workflow_assignments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    document_review_workflow_id INTEGER NOT NULL,
    assigned_user_id INTEGER NOT NULL,
    role_in_workflow TEXT NOT NULL,
    sequence_order INTEGER DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'Pending',
    comments TEXT,
    due_date TEXT,
    completed_at TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (document_review_workflow_id) REFERENCES document_review_workflows(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE electronic_signatures (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    signed_entity_type TEXT NOT NULL,
    signed_entity_id INTEGER NOT NULL,
    signature_meaning TEXT,
    signed_at TEXT DEFAULT CURRENT_TIMESTAMP,
    ip_address TEXT,
    comments TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
);

-- III. Training Management Module Tables
CREATE TABLE training_courses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_code TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    version TEXT DEFAULT '1.0',
    status_item_id INTEGER NOT NULL,
    estimated_duration_minutes INTEGER,
    created_by_user_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (status_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE training_materials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    training_course_id INTEGER NOT NULL,
    material_type TEXT NOT NULL,
    title TEXT NOT NULL,
    source_path_or_link TEXT,
    document_version_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (training_course_id) REFERENCES training_courses(id) ON DELETE CASCADE,
    FOREIGN KEY (document_version_id) REFERENCES document_versions(id) ON DELETE SET NULL
);

CREATE TABLE training_assignments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    training_course_id INTEGER NOT NULL,
    assigned_by_user_id INTEGER,
    assignment_date TEXT DEFAULT CURRENT_TIMESTAMP,
    due_date TEXT,
    status_item_id INTEGER NOT NULL,
    completion_date TEXT,
    score REAL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, training_course_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (training_course_id) REFERENCES training_courses(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (status_item_id) REFERENCES controlled_list_items(id)
);

CREATE TABLE training_curricula (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    created_by_user_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE curriculum_courses (
    curriculum_id INTEGER NOT NULL,
    training_course_id INTEGER NOT NULL,
    sequence_order INTEGER DEFAULT 0,
    PRIMARY KEY (curriculum_id, training_course_id),
    FOREIGN KEY (curriculum_id) REFERENCES training_curricula(id) ON DELETE CASCADE,
    FOREIGN KEY (training_course_id) REFERENCES training_courses(id) ON DELETE CASCADE
);

CREATE TABLE curriculum_assignments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    curriculum_id INTEGER NOT NULL,
    user_id INTEGER,
    role_id INTEGER,
    assigned_by_user_id INTEGER,
    assignment_date TEXT DEFAULT CURRENT_TIMESTAMP,
    due_date TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (curriculum_id) REFERENCES training_curricula(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
    CHECK (user_id IS NOT NULL OR role_id IS NOT NULL)
);

-- IV. Quality Events/Processes Module Tables
CREATE TABLE capas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id_string TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    source_item_id INTEGER,
    status_item_id INTEGER NOT NULL,
    priority_item_id INTEGER,
    initiated_by_user_id INTEGER,
    owner_user_id INTEGER,
    department_affected TEXT,
    initiation_date TEXT DEFAULT CURRENT_TIMESTAMP,
    due_date TEXT,
    completion_date TEXT,
    incident_date TEXT,
    investigation_details TEXT,
    root_cause_analysis_summary TEXT,
    verification_of_effectiveness_summary TEXT,
    closed_by_user_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (initiated_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (source_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (status_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (priority_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (closed_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE capa_actions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    capa_id INTEGER NOT NULL,
    action_type TEXT NOT NULL, -- 'Corrective', 'Preventive'
    description TEXT NOT NULL,
    assigned_to_user_id INTEGER,
    due_date TEXT,
    status_item_id INTEGER NOT NULL, -- FK to controlled_list_items (list_type 'Action Statuses')
    completion_date TEXT,
    verification_notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (capa_id) REFERENCES capas(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (status_item_id) REFERENCES controlled_list_items(id)
);

CREATE TABLE deviations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id_string TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    source_item_id INTEGER,
    status_item_id INTEGER NOT NULL,
    priority_item_id INTEGER,
    initiated_by_user_id INTEGER,
    owner_user_id INTEGER,
    department_affected TEXT,
    initiation_date TEXT DEFAULT CURRENT_TIMESTAMP,
    due_date TEXT,
    completion_date TEXT,
    deviation_date TEXT NOT NULL,
    product_or_process_affected TEXT,
    immediate_actions_taken TEXT,
    impact_assessment TEXT,
    closed_by_user_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (initiated_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (source_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (status_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (priority_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (closed_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE change_controls (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id_string TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    source_item_id INTEGER,
    status_item_id INTEGER NOT NULL,
    priority_item_id INTEGER,
    initiated_by_user_id INTEGER,
    owner_user_id INTEGER,
    department_affected TEXT,
    initiation_date TEXT DEFAULT CURRENT_TIMESTAMP,
    due_date TEXT,
    completion_date TEXT,
    change_type_item_id INTEGER,
    justification_for_change TEXT,
    proposed_change_description TEXT,
    impact_assessment_summary TEXT,
    implementation_plan_summary TEXT,
    pre_approval_status_item_id INTEGER,
    post_implementation_review_summary TEXT,
    closed_by_user_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (initiated_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (source_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (status_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (priority_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (change_type_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (pre_approval_status_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (closed_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE audits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id_string TEXT UNIQUE NOT NULL, -- Audit Number
    title TEXT NOT NULL,
    description TEXT,
    source_item_id INTEGER, -- N/A for audits, or could be 'Internal', 'External Trigger'
    status_item_id INTEGER NOT NULL,
    priority_item_id INTEGER,
    initiated_by_user_id INTEGER, -- Scheduler/Planner
    owner_user_id INTEGER, -- Could be Lead Auditor or Audit Program Manager
    department_affected TEXT, -- Department being audited
    initiation_date TEXT DEFAULT CURRENT_TIMESTAMP, -- Date audit record created/planned
    due_date TEXT, -- Planned completion date
    completion_date TEXT, -- Actual completion date
    audit_type_item_id INTEGER,
    scope TEXT,
    objectives TEXT,
    criteria TEXT,
    lead_auditor_user_id INTEGER,
    planned_start_date TEXT,
    planned_end_date TEXT,
    actual_start_date TEXT,
    actual_end_date TEXT,
    audit_report_path TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (initiated_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (status_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (priority_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (audit_type_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (lead_auditor_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE audit_team_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    audit_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    role_in_audit_item_id INTEGER NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (audit_id, user_id),
    FOREIGN KEY (audit_id) REFERENCES audits(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_in_audit_item_id) REFERENCES controlled_list_items(id)
);

CREATE TABLE audit_findings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    audit_id INTEGER NOT NULL,
    finding_id_string TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL,
    classification_item_id INTEGER NOT NULL,
    evidence TEXT,
    reference_clause TEXT,
    assigned_to_user_id INTEGER,
    due_date_for_response TEXT,
    status_item_id INTEGER NOT NULL,
    capa_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (audit_id) REFERENCES audits(id) ON DELETE CASCADE,
    FOREIGN KEY (classification_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (assigned_to_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (status_item_id) REFERENCES controlled_list_items(id),
    FOREIGN KEY (capa_id) REFERENCES capas(id) ON DELETE SET NULL
);

CREATE TABLE attachments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_mime_type TEXT,
    file_size_bytes INTEGER,
    uploaded_by_user_id INTEGER,
    uploaded_at TEXT DEFAULT CURRENT_TIMESTAMP,
    parent_entity_type TEXT NOT NULL,
    parent_entity_id INTEGER NOT NULL,
    FOREIGN KEY (uploaded_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE related_qms_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_entity_type TEXT NOT NULL,
    source_entity_id INTEGER NOT NULL,
    target_entity_type TEXT NOT NULL,
    target_entity_id INTEGER NOT NULL,
    relationship_type TEXT,
    created_by_user_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE (source_entity_type, source_entity_id, target_entity_type, target_entity_id, relationship_type)
);

-- V. Reporting & Analytics Pages
CREATE TABLE standard_reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    report_name TEXT UNIQUE NOT NULL,
    description TEXT,
    module TEXT,
    query_definition TEXT,
    default_parameters_json TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE custom_reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    report_name TEXT NOT NULL,
    description TEXT,
    created_by_user_id INTEGER NOT NULL,
    data_source_details_json TEXT,
    chart_options_json TEXT,
    is_shared INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- VI. System & Support Pages
CREATE TABLE help_article_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INTEGER,
    sort_order INTEGER DEFAULT 0,
    FOREIGN KEY (parent_category_id) REFERENCES help_article_categories(id) ON DELETE SET NULL
);

CREATE TABLE help_articles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER,
    title TEXT NOT NULL,
    content_html TEXT NOT NULL,
    keywords TEXT,
    created_by_user_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES help_article_categories(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT,
    related_entity_type TEXT,
    related_entity_id INTEGER,
    is_read INTEGER DEFAULT 0,
    read_at TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);