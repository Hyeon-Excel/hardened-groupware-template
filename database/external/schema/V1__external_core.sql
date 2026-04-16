-- V1__external_core.sql
-- Core schema for external service domain.

CREATE TABLE IF NOT EXISTS external_users (
  user_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  login_id VARCHAR(80) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  KEY idx_external_users_status_created_at (status, created_at)
);

CREATE TABLE IF NOT EXISTS external_news (
  news_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  summary VARCHAR(500),
  content TEXT NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  KEY idx_external_news_created_at (created_at)
);

CREATE TABLE IF NOT EXISTS external_notices (
  notice_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  summary VARCHAR(500),
  content TEXT NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  KEY idx_external_notices_created_at (created_at)
);

CREATE TABLE IF NOT EXISTS external_resources (
  resource_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  description VARCHAR(1000),
  file_id VARCHAR(100) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  KEY idx_external_resources_status_created_at (status, created_at)
);

CREATE TABLE IF NOT EXISTS support_tickets (
  ticket_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  category VARCHAR(20) NOT NULL DEFAULT 'OTHER',
  title VARCHAR(200) NOT NULL,
  content TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'RECEIVED',
  file_id VARCHAR(100),
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  CONSTRAINT fk_support_ticket_user
    FOREIGN KEY (user_id) REFERENCES external_users(user_id),
  KEY idx_support_tickets_user_created_at (user_id, created_at),
  KEY idx_support_tickets_status_created_at (status, created_at)
);

CREATE TABLE IF NOT EXISTS careers (
  career_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  department VARCHAR(120),
  description TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
  deadline DATETIME,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  KEY idx_careers_status_deadline (status, deadline),
  KEY idx_careers_created_at (created_at)
);

CREATE TABLE IF NOT EXISTS career_applications (
  application_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  career_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(40),
  cover_letter TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'SUBMITTED',
  file_id VARCHAR(100),
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  CONSTRAINT fk_application_career
    FOREIGN KEY (career_id) REFERENCES careers(career_id),
  CONSTRAINT fk_application_user
    FOREIGN KEY (user_id) REFERENCES external_users(user_id),
  CONSTRAINT uk_career_applications_career_user UNIQUE (career_id, user_id),
  KEY idx_career_applications_user_created_at (user_id, created_at),
  KEY idx_career_applications_status_created_at (status, created_at)
);

CREATE TABLE IF NOT EXISTS file_scan_jobs (
  job_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  file_id VARCHAR(100) NOT NULL UNIQUE,
  source_type VARCHAR(40) NOT NULL,
  source_id BIGINT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  reason VARCHAR(200),
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  KEY idx_file_scan_jobs_status_updated_at (status, updated_at),
  KEY idx_file_scan_jobs_source (source_type, source_id)
);
