-- Indexes for Core & Common Tables
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX idx_role_permissions_permission_id ON role_permissions(permission_id);
CREATE INDEX idx_audit_trails_user_id ON audit_trails(user_id);
CREATE INDEX idx_audit_trails_entity ON audit_trails(entity_type, entity_id);
CREATE INDEX idx_audit_trails_timestamp ON audit_trails(timestamp);
CREATE INDEX idx_delegations_delegatee_user_id ON delegations(delegatee_user_id);
CREATE INDEX idx_controlled_list_items_list_type_id ON controlled_list_items(list_type_id);

-- Indexes for Document Management
CREATE INDEX idx_documents_title ON documents(title);
CREATE INDEX idx_documents_document_type_item_id ON documents(document_type_item_id);
CREATE INDEX idx_document_versions_document_id ON document_versions(document_id);
CREATE INDEX idx_document_versions_status_item_id ON document_versions(status_item_id);
CREATE INDEX idx_document_review_workflows_document_version_id ON document_review_workflows(document_version_id);
CREATE INDEX idx_document_workflow_assignments_assigned_user_id ON document_workflow_assignments(assigned_user_id);
CREATE INDEX idx_electronic_signatures_entity ON electronic_signatures(signed_entity_type, signed_entity_id);

-- Indexes for Training Management
CREATE INDEX idx_training_courses_title ON training_courses(title);
CREATE INDEX idx_training_courses_status_item_id ON training_courses(status_item_id);
CREATE INDEX idx_training_materials_training_course_id ON training_materials(training_course_id);
CREATE INDEX idx_training_assignments_user_id ON training_assignments(user_id);
CREATE INDEX idx_training_assignments_training_course_id ON training_assignments(training_course_id);
CREATE INDEX idx_training_assignments_status_item_id ON training_assignments(status_item_id);
CREATE INDEX idx_curriculum_courses_training_course_id ON curriculum_courses(training_course_id);
CREATE INDEX idx_curriculum_assignments_user_id ON curriculum_assignments(user_id);
CREATE INDEX idx_curriculum_assignments_role_id ON curriculum_assignments(role_id);


-- Indexes for Quality Events
CREATE INDEX idx_capas_status_item_id ON capas(status_item_id);
CREATE INDEX idx_capas_owner_user_id ON capas(owner_user_id);
CREATE INDEX idx_capa_actions_capa_id ON capa_actions(capa_id);
CREATE INDEX idx_capa_actions_status_item_id ON capa_actions(status_item_id);
CREATE INDEX idx_deviations_status_item_id ON deviations(status_item_id);
CREATE INDEX idx_deviations_owner_user_id ON deviations(owner_user_id);
CREATE INDEX idx_change_controls_status_item_id ON change_controls(status_item_id);
CREATE INDEX idx_change_controls_owner_user_id ON change_controls(owner_user_id);
CREATE INDEX idx_audits_status_item_id ON audits(status_item_id);
CREATE INDEX idx_audits_lead_auditor_user_id ON audits(lead_auditor_user_id);
CREATE INDEX idx_audit_team_members_user_id ON audit_team_members(user_id);
CREATE INDEX idx_audit_findings_audit_id ON audit_findings(audit_id);
CREATE INDEX idx_audit_findings_status_item_id ON audit_findings(status_item_id);
CREATE INDEX idx_attachments_parent_entity ON attachments(parent_entity_type, parent_entity_id);
CREATE INDEX idx_related_qms_records_source ON related_qms_records(source_entity_type, source_entity_id);
CREATE INDEX idx_related_qms_records_target ON related_qms_records(target_entity_type, target_entity_id);


-- Indexes for Reporting & Analytics
CREATE INDEX idx_custom_reports_created_by_user_id ON custom_reports(created_by_user_id);

-- Indexes for System & Support
CREATE INDEX idx_help_articles_category_id ON help_articles(category_id);
CREATE INDEX idx_help_articles_title ON help_articles(title);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);