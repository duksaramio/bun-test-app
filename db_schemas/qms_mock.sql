-- Current Datetime for created_at / updated_at
-- For SQLite, we can use datetime('now') or strftime('%Y-%m-%d %H:%M:%S', 'now')
-- Let's pre-define some dates for consistency in mock data
-- (In real inserts, CURRENT_TIMESTAMP or dynamic values would be used)
-- For password_hash, use a placeholder like 'hashed_password_placeholder'

-- I. Core & Common Mock Data

-- Users
INSERT INTO users (username, password_hash, email, first_name, last_name, department, job_title, is_active, created_at, updated_at) VALUES
('admin', 'hashed_password_admin', 'admin@qms.com', 'Admin', 'User', 'IT', 'System Administrator', 1, '2024-01-01 10:00:00', '2024-01-01 10:00:00'),
('jdoe', 'hashed_password_jdoe', 'jdoe@qms.com', 'John', 'Doe', 'Manufacturing', 'Operator', 1, '2024-01-02 11:00:00', '2024-01-02 11:00:00'),
('asmith', 'hashed_password_asmith', 'asmith@qms.com', 'Alice', 'Smith', 'QA', 'QA Specialist', 1, '2024-01-03 12:00:00', '2024-01-03 12:00:00'),
('bking', 'hashed_password_bking', 'bking@qms.com', 'Bob', 'King', 'Engineering', 'Engineer', 1, '2024-01-04 13:00:00', '2024-01-04 13:00:00'),
('cwhite', 'hashed_password_cwhite', 'cwhite@qms.com', 'Carol', 'White', 'Training', 'Training Coordinator', 1, '2024-01-05 14:00:00', '2024-01-05 14:00:00');

-- Roles
INSERT INTO roles (name, description, created_at, updated_at) VALUES
('System Administrator', 'Full access to system configuration and user management.', '2024-01-01 09:00:00', '2024-01-01 09:00:00'),
('Document Author', 'Can create and revise documents.', '2024-01-01 09:00:00', '2024-01-01 09:00:00'),
('Document Reviewer', 'Can review documents.', '2024-01-01 09:00:00', '2024-01-01 09:00:00'),
('Document Approver', 'Can approve documents.', '2024-01-01 09:00:00', '2024-01-01 09:00:00'),
('QA Manager', 'Manages quality events and processes.', '2024-01-01 09:00:00', '2024-01-01 09:00:00'),
('Trainee', 'General user who undergoes training.', '2024-01-01 09:00:00', '2024-01-01 09:00:00'),
('Training Administrator', 'Manages training content and assignments.', '2024-01-01 09:00:00', '2024-01-01 09:00:00');

-- User Roles (Manually map IDs: admin=1, jdoe=2, asmith=3, bking=4, cwhite=5 | SysAdmin=1, Author=2, Reviewer=3, Approver=4, QAManager=5, Trainee=6, TrainAdmin=7)
INSERT INTO user_roles (user_id, role_id) VALUES
(1, 1), -- admin is System Administrator
(2, 2), (2, 6), -- jdoe is Document Author and Trainee
(3, 3), (3, 4), (3, 5), -- asmith is Reviewer, Approver, QA Manager
(4, 2), (4, 3), -- bking is Author, Reviewer
(5, 7), (5, 6); -- cwhite is Training Admin, Trainee

-- Permissions (Example - more would be needed)
INSERT INTO permissions (name, description) VALUES
('system:administer', 'Full system administration'),
('document:create', 'Create new documents'),
('document:revise', 'Revise existing documents'),
('document:review', 'Review documents'),
('document:approve', 'Approve documents'),
('training:manage', 'Manage training courses and assignments'),
('capa:initiate', 'Initiate new CAPAs'),
('user:manage', 'Manage user accounts');

-- Role Permissions (Example)
-- SysAdmin (Role ID 1)
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 1), (1, 8); -- System Admin can administer and manage users
-- Document Author (Role ID 2)
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 2), (2, 3);
-- Document Reviewer (Role ID 3)
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 4);
-- Document Approver (Role ID 4)
INSERT INTO role_permissions (role_id, permission_id) VALUES (4, 5);
-- QA Manager (Role ID 5)
INSERT INTO role_permissions (role_id, permission_id) VALUES (5, 7); -- Can initiate CAPAs
-- Training Admin (Role ID 7)
INSERT INTO role_permissions (role_id, permission_id) VALUES (7, 6);


-- User Settings (Assuming user_id 1 for admin, 2 for jdoe)
INSERT INTO user_settings (user_id, language_preference, timezone_preference, email_notifications_enabled, in_app_notifications_enabled) VALUES
(1, 'en-US', 'America/New_York', 1, 1),
(2, 'en-GB', 'Europe/London', 1, 0);

-- System Announcements
INSERT INTO system_announcements (title, content, created_by_user_id, start_date, end_date, is_active) VALUES
('Scheduled Maintenance', 'The system will be down for scheduled maintenance on 2025-06-15 from 02:00 to 04:00 UTC.', 1, '2025-06-01 00:00:00', '2025-06-15 04:00:00', 1),
('New Training Module Available', 'Check out the new training module on Data Integrity, course code TRN-005.', 1, '2025-05-10 00:00:00', '2025-07-10 00:00:00', 1);

-- Controlled List Types
INSERT INTO controlled_list_types (name, description) VALUES
('Document Types', 'Types of controlled documents like SOP, WI, etc.'),
('Document Statuses', 'Lifecycle statuses for documents'),
('Training Course Statuses', 'Statuses for training courses'),
('Training Assignment Statuses', 'Statuses for training assignments for users'),
('CAPA Sources', 'Origin sources for Corrective and Preventive Actions'),
('CAPA Statuses', 'Lifecycle statuses for CAPAs'),
('Action Statuses', 'Statuses for actions within CAPAs or other events'),
('Priority Levels', 'General priority levels for tasks and events'),
('Deviation Sources', 'Origin sources for Deviations'),
('Deviation Statuses', 'Lifecycle statuses for Deviations'),
('Change Control Types', 'Types of changes managed'),
('Change Control Statuses', 'Lifecycle statuses for Change Controls'),
('Approval Statuses', 'General approval statuses'),
('Audit Types', 'Types of audits (Internal, External, Supplier)'),
('Audit Statuses', 'Lifecycle statuses for Audits'),
('Audit Team Roles', 'Roles of individuals within an audit team'),
('Finding Classifications', 'Classifications for audit findings (Major, Minor, OFI)'),
('Finding Statuses', 'Lifecycle statuses for audit findings');

-- Controlled List Items (Example - This would be extensive. IDs are important for FKs later)
-- Document Types (List Type ID 1)
INSERT INTO controlled_list_items (list_type_id, item_value, item_description) VALUES
( (SELECT id from controlled_list_types where name='Document Types'), 'SOP', 'Standard Operating Procedure'), -- Item ID 1
( (SELECT id from controlled_list_types where name='Document Types'), 'WI', 'Work Instruction'),          -- Item ID 2
( (SELECT id from controlled_list_types where name='Document Types'), 'Policy', 'Company Policy');          -- Item ID 3

-- Document Statuses (List Type ID 2)
INSERT INTO controlled_list_items (list_type_id, item_value, item_description) VALUES
( (SELECT id from controlled_list_types where name='Document Statuses'), 'Draft', 'Document is in draft state'), -- Item ID 4
( (SELECT id from controlled_list_types where name='Document Statuses'), 'In Review', 'Document is under review'), -- Item ID 5
( (SELECT id from controlled_list_types where name='Document Statuses'), 'Approved', 'Document is approved, pending effectiveness'), -- Item ID 6
( (SELECT id from controlled_list_types where name='Document Statuses'), 'Effective', 'Document is effective and in use'), -- Item ID 7
( (SELECT id from controlled_list_types where name='Document Statuses'), 'Obsolete', 'Document is no longer in use'); -- Item ID 8

-- Training Course Statuses (List Type ID 3)
INSERT INTO controlled_list_items (list_type_id, item_value, item_description) VALUES
( (SELECT id from controlled_list_types where name='Training Course Statuses'), 'Active', 'Course is active and can be assigned'), -- Item ID 9
( (SELECT id from controlled_list_types where name='Training Course Statuses'), 'Inactive', 'Course is inactive and cannot be assigned'); -- Item ID 10

-- Training Assignment Statuses (List Type ID 4)
INSERT INTO controlled_list_items (list_type_id, item_value, item_description) VALUES
( (SELECT id from controlled_list_types where name='Training Assignment Statuses'), 'Pending', 'Training assigned, not started'), -- Item ID 11
( (SELECT id from controlled_list_types where name='Training Assignment Statuses'), 'In Progress', 'Training started'), -- Item ID 12
( (SELECT id from controlled_list_types where name='Training Assignment Statuses'), 'Completed', 'Training successfully completed'), -- Item ID 13
( (SELECT id from controlled_list_types where name='Training Assignment Statuses'), 'Overdue', 'Training not completed by due date'); -- Item ID 14

-- CAPA Statuses (List Type ID 6)
INSERT INTO controlled_list_items (list_type_id, item_value, item_description) VALUES
( (SELECT id from controlled_list_types where name='CAPA Statuses'), 'Open', 'CAPA initiated and open'), -- Item ID 15
( (SELECT id from controlled_list_types where name='CAPA Statuses'), 'Investigation', 'CAPA under investigation'), -- Item ID 16
( (SELECT id from controlled_list_types where name='CAPA Statuses'), 'Actions Pending', 'CAPA actions defined and pending completion'), -- Item ID 17
( (SELECT id from controlled_list_types where name='CAPA Statuses'), 'Closed', 'CAPA completed and closed'); -- Item ID 18

-- Priority Levels (List Type ID 8)
INSERT INTO controlled_list_items (list_type_id, item_value, item_description) VALUES
( (SELECT id from controlled_list_types where name='Priority Levels'), 'High', 'High priority'), -- Item ID 19
( (SELECT id from controlled_list_types where name='Priority Levels'), 'Medium', 'Medium priority'), -- Item ID 20
( (SELECT id from controlled_list_types where name='Priority Levels'), 'Low', 'Low priority'); -- Item ID 21

-- Action Statuses (List Type ID 7)
INSERT INTO controlled_list_items (list_type_id, item_value, item_description) VALUES
( (SELECT id from controlled_list_types where name='Action Statuses'), 'Open', 'Action is open'), -- Item ID 22
( (SELECT id from controlled_list_types where name='Action Statuses'), 'In Progress', 'Action is in progress'), -- Item ID 23
( (SELECT id from controlled_list_types where name='Action Statuses'), 'Completed', 'Action is completed'), -- Item ID 24
( (SELECT id from controlled_list_types where name='Action Statuses'), 'Cancelled', 'Action is cancelled'); -- Item ID 25


-- II. Document Management Mock Data

-- Documents (doc_type_item_id: SOP=1, WI=2. owner_user_id: jdoe=2, bking=4)
INSERT INTO documents (document_number, title, document_type_item_id, owner_user_id, created_at, updated_at) VALUES
('SOP-001', 'Standard Operating Procedure for Equipment Calibration', 1, 2, '2024-02-01 09:00:00', '2024-02-01 09:00:00'),
('WI-001', 'Work Instruction for Sample Preparation', 2, 4, '2024-03-01 10:00:00', '2024-03-01 10:00:00');

-- Document Versions (doc_id: SOP-001=1, WI-001=2. status_item_id: Draft=4, In Review=5, Effective=7. uploaded_by_user_id: jdoe=2, bking=4)
INSERT INTO document_versions (document_id, version_number, status_item_id, effective_date, change_summary, file_name, file_path, file_mime_type, uploaded_by_user_id, created_at, updated_at) VALUES
(1, '1.0', 7, '2024-02-15 00:00:00', 'Initial release.', 'SOP-001_v1.0.pdf', '/files/SOP-001_v1.0.pdf', 'application/pdf', 2, '2024-02-01 09:30:00', '2024-02-10 14:00:00'),
(1, '1.1', 5, NULL, 'Minor updates to section 3.2.', 'SOP-001_v1.1.pdf', '/files/SOP-001_v1.1.pdf', 'application/pdf', 2, '2025-05-01 11:00:00', '2025-05-01 11:00:00'),
(2, '1.0', 4, NULL, 'Draft for review.', 'WI-001_v1.0.pdf', '/files/WI-001_v1.0.pdf', 'application/pdf', 4, '2024-03-01 10:30:00', '2024-03-01 10:30:00');

-- Document Review Workflows (doc_version_id: SOP-001_v1.1=2, WI-001_v1.0=3)
INSERT INTO document_review_workflows (document_version_id, workflow_type, status, created_at) VALUES
(2, 'Sequential', 'In Progress', '2025-05-01 11:05:00'), -- Workflow for SOP-001 v1.1
(3, 'Parallel', 'Pending', '2024-03-01 10:35:00');    -- Workflow for WI-001 v1.0

-- Document Workflow Assignments (workflow_id: 1 for SOP, 2 for WI. assigned_user_id: asmith=3, bking=4)
-- For SOP-001 v1.1 (workflow_id 1)
INSERT INTO document_workflow_assignments (document_review_workflow_id, assigned_user_id, role_in_workflow, sequence_order, status, due_date, created_at) VALUES
(1, 3, 'Reviewer', 1, 'Pending', '2025-05-15 17:00:00', '2025-05-01 11:10:00'), -- Alice Smith to review
(1, 4, 'Approver', 2, 'Pending', '2025-05-20 17:00:00', '2025-05-01 11:10:00'); -- Bob King to approve

-- For WI-001 v1.0 (workflow_id 2)
INSERT INTO document_workflow_assignments (document_review_workflow_id, assigned_user_id, role_in_workflow, sequence_order, status, due_date, created_at) VALUES
(2, 2, 'Reviewer', 1, 'Pending', '2024-03-15 17:00:00', '2024-03-01 10:40:00'), -- John Doe to review
(2, 3, 'Approver', 1, 'Pending', '2024-03-15 17:00:00', '2024-03-01 10:40:00'); -- Alice Smith to approve (parallel)


-- III. Training Management Mock Data

-- Training Courses (status_item_id: Active=9. created_by_user_id: cwhite=5)
INSERT INTO training_courses (course_code, title, description, version, status_item_id, estimated_duration_minutes, created_by_user_id) VALUES
('TRN-001', 'Good Manufacturing Practices (GMP)', 'Basic GMP principles.', '1.0', 9, 60, 5),
('TRN-002', 'SOP-001 Training', 'Training on SOP-001 Equipment Calibration.', '1.0', 9, 30, 5),
('TRN-003', 'Safety Procedures', 'General workplace safety.', '2.1', 9, 45, 5);

-- Training Materials (course_id: TRN-001=1, TRN-002=2. doc_version_id: SOP-001_v1.0=1)
INSERT INTO training_materials (training_course_id, material_type, title, source_path_or_link, document_version_id) VALUES
(1, 'Document', 'GMP Fundamentals Guide', '/materials/gmp_guide.pdf', NULL),
(2, 'Document', 'SOP-001 Equipment Calibration v1.0', NULL, 1), -- Links to document_versions ID 1
(3, 'Video', 'Workplace Safety Video', 'https://example.com/safety_video', NULL);

-- Training Assignments (user_id: jdoe=2, asmith=3. course_id: TRN-001=1, TRN-002=2. assigned_by_user_id: cwhite=5. status_item_id: Pending=11, Completed=13, Overdue=14)
INSERT INTO training_assignments (user_id, training_course_id, assigned_by_user_id, due_date, status_item_id, completion_date) VALUES
(2, 1, 5, '2025-05-30', 11, NULL), -- John Doe, GMP Training, Pending
(2, 2, 5, '2025-04-30', 14, NULL), -- John Doe, SOP-001 Training, Overdue
(3, 1, 5, '2025-05-15', 13, '2025-05-10 10:00:00'); -- Alice Smith, GMP Training, Completed

-- IV. Quality Events Mock Data

-- CAPAs (initiated_by_user_id: asmith=3. owner_user_id: bking=4. status_item_id: Open=15, Investigation=16. priority_item_id: High=19)
INSERT INTO capas (event_id_string, title, description, status_item_id, priority_item_id, initiated_by_user_id, owner_user_id, initiation_date, due_date) VALUES
('CAPA-2025-001', 'Out of Specification Result in Product X', 'OOS found during routine testing.', 16, 19, 3, 4, '2025-04-10 09:00:00', '2025-06-10');

-- CAPA Actions (capa_id: CAPA-2025-001=1. assigned_to_user_id: bking=4. status_item_id: Open=22)
INSERT INTO capa_actions (capa_id, action_type, description, assigned_to_user_id, due_date, status_item_id) VALUES
(1, 'Corrective', 'Investigate root cause of OOS.', 4, '2025-05-10', 22),
(1, 'Preventive', 'Review related processes for similar risks.', 4, '2025-05-20', 22);

-- Notifications (user_id: jdoe=2, asmith=3, bking=4)
INSERT INTO notifications (user_id, title, message, type, related_entity_type, related_entity_id, is_read) VALUES
(4, 'New CAPA Assigned', 'You have been assigned as owner for CAPA-2025-001.', 'TaskAssignment', 'CAPA', 1, 0),
(2, 'Training Overdue', 'Your training for SOP-001 is overdue.', 'OverdueAlert', 'TrainingAssignment', 2, 0), -- Assuming TrainingAssignment ID 2 is John's overdue SOP training
(3, 'Document Review Request', 'SOP-001 v1.1 is awaiting your review.', 'ApprovalRequest', 'DocumentWorkflowAssignment', 1, 0); -- Assuming DWA ID 1 is Alice's review for SOP-001 v1.1

-- Attachments (Example: Attaching a file to CAPA-2025-001. uploaded_by_user_id: asmith=3)
INSERT INTO attachments (file_name, file_path, file_mime_type, file_size_bytes, uploaded_by_user_id, parent_entity_type, parent_entity_id) VALUES
('OOS_Lab_Report.pdf', '/attachments/oos_lab_report.pdf', 'application/pdf', 102400, 3, 'CAPA', 1);

-- Electronic Signatures (Example: Alice Smith reviews a document. user_id=3. signed_entity_type: DocumentWorkflowAssignment, signed_entity_id matches a DWA ID)
-- Assuming DWA ID 1 is for Alice Smith reviewing SOP-001 v1.1
-- First, update the DWA status
UPDATE document_workflow_assignments
SET status = 'Reviewed', completed_at = '2025-05-12 14:30:00', comments = 'Reviewed, looks good.'
WHERE id = 1; -- This is Alice Smith's review task for SOP-001 v1.1

INSERT INTO electronic_signatures (user_id, signed_entity_type, signed_entity_id, signature_meaning, comments, ip_address, signed_at) VALUES
(3, 'DocumentWorkflowAssignment', 1, 'Review Acknowledgement', 'Reviewed, looks good.', '192.168.1.101', '2025-05-12 14:30:00');


-- Audit Trail (Example: User login, Document creation)
-- User login (admin user, ID 1)
INSERT INTO audit_trails (user_id, action_performed, ip_address, timestamp) VALUES
(1, 'USER_LOGIN_SUCCESS', '192.168.1.100', '2025-05-06 10:00:00');
-- Document SOP-001 (ID 1) created by jdoe (ID 2)
INSERT INTO audit_trails (user_id, action_performed, entity_type, entity_id, change_details, timestamp) VALUES
(2, 'DOCUMENT_CREATED', 'Document', 1, '{"document_number": "SOP-001", "title": "Standard Operating Procedure for Equipment Calibration"}', '2024-02-01 09:00:00');
-- Document Version SOP-001 v1.0 (ID 1) created
INSERT INTO audit_trails (user_id, action_performed, entity_type, entity_id, change_details, timestamp) VALUES
(2, 'DOCUMENT_VERSION_CREATED', 'DocumentVersion', 1, '{"version_number": "1.0", "status": "Effective"}', '2024-02-01 09:30:00');