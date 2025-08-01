-- ========================================
-- Prompt Lab Database Initialization Script
-- ========================================
-- 이 스크립트는 Docker 컨테이너 시작 시 실행됩니다.
-- 기존 데이터를 완전히 삭제하고 새로운 데이터베이스를 초기화합니다.

-- 데이터베이스 생성 (PostgreSQL 문법)
-- PostgreSQL에서는 IF NOT EXISTS를 지원하지 않으므로 다른 방식 사용
SELECT 'CREATE DATABASE prompt_lab'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'prompt_lab')\gexec

-- prompt_lab 데이터베이스에 연결
\c prompt_lab;

-- 기존 데이터 완전 삭제 (테이블이 존재하는 경우)
DROP TABLE IF EXISTS "user" CASCADE;
DROP TABLE IF EXISTS team CASCADE;

-- pgcrypto 확장 설치 (UUID 생성용)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ========================================
-- 테이블 생성
-- ========================================

-- team 테이블 생성
CREATE TABLE team (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    payment VARCHAR(20) NOT NULL DEFAULT 'free',
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now()
);

-- user 테이블 생성
CREATE TABLE "user" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    app_id VARCHAR(50) NOT NULL UNIQUE,
    app_password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    team_id UUID NOT NULL REFERENCES team(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now()
);

-- ========================================
-- 인덱스 생성 (성능 최적화)
-- ========================================
CREATE INDEX idx_user_team_id ON "user"(team_id);
CREATE INDEX idx_user_app_id ON "user"(app_id);
CREATE INDEX idx_team_name ON team(name);
CREATE INDEX idx_user_created_at ON "user"(created_at);
CREATE INDEX idx_team_created_at ON team(created_at);

-- ========================================
-- 제약 조건 추가
-- ========================================
-- app_id는 고유해야 함
ALTER TABLE "user" ADD CONSTRAINT uk_user_app_id UNIQUE (app_id);

-- 팀 이름은 고유해야 함
ALTER TABLE team ADD CONSTRAINT uk_team_name UNIQUE (name);

-- ========================================
-- 기본 데이터 삽입 (옵션)
-- ========================================
-- 기본 팀 생성
INSERT INTO team (name, payment) 
VALUES ('Default Team', 'free')
ON CONFLICT (name) DO NOTHING;

-- ========================================
-- 완료 메시지
-- ========================================
\echo '========================================'
\echo 'Database initialization completed successfully!'
\echo '========================================'
\echo 'Tables created:'
\echo '  - team'
\echo '  - user'
\echo '========================================' 