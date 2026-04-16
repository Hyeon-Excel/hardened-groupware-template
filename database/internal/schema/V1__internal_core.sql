-- V1__internal_core.sql
-- Core schema for internal groupware domain.

CREATE TABLE IF NOT EXISTS internal_employees (
  employee_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  employee_no VARCHAR(40) NOT NULL UNIQUE,
  login_id VARCHAR(80) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(120) NOT NULL,
  department VARCHAR(120),
  position VARCHAR(120),
  role VARCHAR(20) NOT NULL DEFAULT 'EMPLOYEE',
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  KEY idx_internal_employees_role_status (role, status)
);

CREATE TABLE IF NOT EXISTS internal_notices (
  notice_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  content TEXT NOT NULL,
  author_employee_id BIGINT NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  CONSTRAINT fk_internal_notice_author
    FOREIGN KEY (author_employee_id) REFERENCES internal_employees(employee_id),
  KEY idx_internal_notices_created_at (created_at),
  KEY idx_internal_notices_author_created_at (author_employee_id, created_at)
);

CREATE TABLE IF NOT EXISTS approvals (
  approval_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  content TEXT NOT NULL,
  requester_employee_id BIGINT NOT NULL,
  approver_employee_id BIGINT,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  CONSTRAINT fk_approval_requester
    FOREIGN KEY (requester_employee_id) REFERENCES internal_employees(employee_id),
  CONSTRAINT fk_approval_approver
    FOREIGN KEY (approver_employee_id) REFERENCES internal_employees(employee_id),
  KEY idx_approvals_requester_created_at (requester_employee_id, created_at),
  KEY idx_approvals_approver_status (approver_employee_id, status),
  KEY idx_approvals_status_created_at (status, created_at)
);

-- NOTE:
-- Cross-DB FK(external_db -> internal_db)는 사용할 수 없으므로,
-- internal_db에 외부 엔티티 참조 미러 테이블을 두고 내부 FK를 복구한다.
CREATE TABLE IF NOT EXISTS external_application_refs (
  application_id BIGINT PRIMARY KEY,
  external_user_id BIGINT NOT NULL,
  career_id BIGINT NOT NULL,
  application_status VARCHAR(20) NOT NULL,
  synced_at DATETIME NOT NULL,
  KEY idx_external_application_refs_user (external_user_id),
  KEY idx_external_application_refs_status (application_status),
  KEY idx_external_application_refs_synced_at (synced_at)
);

CREATE TABLE IF NOT EXISTS external_support_ticket_refs (
  ticket_id BIGINT PRIMARY KEY,
  external_user_id BIGINT NOT NULL,
  ticket_status VARCHAR(20) NOT NULL,
  synced_at DATETIME NOT NULL,
  KEY idx_external_support_ticket_refs_user (external_user_id),
  KEY idx_external_support_ticket_refs_status (ticket_status),
  KEY idx_external_support_ticket_refs_synced_at (synced_at)
);

CREATE TABLE IF NOT EXISTS applicant_notes (
  note_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  application_id BIGINT NOT NULL,
  author_employee_id BIGINT NOT NULL,
  note TEXT NOT NULL,
  created_at DATETIME NOT NULL,
  CONSTRAINT fk_applicant_note_application_ref
    FOREIGN KEY (application_id) REFERENCES external_application_refs(application_id),
  CONSTRAINT fk_applicant_note_author
    FOREIGN KEY (author_employee_id) REFERENCES internal_employees(employee_id),
  KEY idx_applicant_notes_application_created_at (application_id, created_at)
);

CREATE TABLE IF NOT EXISTS support_ticket_replies (
  reply_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  ticket_id BIGINT NOT NULL,
  responder_employee_id BIGINT NOT NULL,
  reply TEXT NOT NULL,
  created_at DATETIME NOT NULL,
  CONSTRAINT fk_ticket_reply_ticket_ref
    FOREIGN KEY (ticket_id) REFERENCES external_support_ticket_refs(ticket_id),
  CONSTRAINT fk_ticket_reply_author
    FOREIGN KEY (responder_employee_id) REFERENCES internal_employees(employee_id),
  KEY idx_support_ticket_replies_ticket_created_at (ticket_id, created_at)
);

CREATE TABLE IF NOT EXISTS audit_logs (
  audit_log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  actor_employee_id BIGINT NOT NULL,
  action VARCHAR(120) NOT NULL,
  target_type VARCHAR(80) NOT NULL,
  target_id VARCHAR(120) NOT NULL,
  metadata_json JSON,
  created_at DATETIME NOT NULL,
  CONSTRAINT fk_audit_actor
    FOREIGN KEY (actor_employee_id) REFERENCES internal_employees(employee_id),
  KEY idx_audit_logs_actor_created_at (actor_employee_id, created_at),
  KEY idx_audit_logs_target (target_type, target_id),
  KEY idx_audit_logs_action_created_at (action, created_at)
);
