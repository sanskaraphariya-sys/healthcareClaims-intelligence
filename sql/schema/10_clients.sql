-- ==============================================================================
-- TENANT & ADMINISTRATIVE LAYER
-- ==============================================================================

CREATE TABLE clients (
    client_id BIGINT GENERATED ALWAYS AS IDENTITY,
    client_name VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_clients PRIMARY KEY (client_id),
    CONSTRAINT uq_clients_name UNIQUE (client_name)
);

COMMENT ON TABLE clients IS 'The organizations (e.g., TPAs, investigative vendors) purchasing the platform.';

CREATE TABLE payers (
    payer_id BIGINT GENERATED ALWAYS AS IDENTITY,
    client_id BIGINT NOT NULL,
    payer_name VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_payers PRIMARY KEY (payer_id),
    CONSTRAINT fk_payers_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE RESTRICT,
    CONSTRAINT uq_payers_client_name UNIQUE (client_id, payer_name)
);

COMMENT ON TABLE payers IS 'The health plans or insurance carriers associated with a specific client.';

CREATE TABLE reviewers (
    reviewer_id BIGINT GENERATED ALWAYS AS IDENTITY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    -- e.g., 'CLINICAL_INVESTIGATOR', 'NON_CLINICAL_INVESTIGATOR', 'SENIOR_CLINICAL_INVESTIGATOR'
    reviewer_role VARCHAR(50) NOT NULL, 
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_reviewers PRIMARY KEY (reviewer_id),
    CONSTRAINT uq_reviewers_email UNIQUE (email)
);

COMMENT ON TABLE reviewers IS 'Platform users who allocate, investigate, and make clinical decisions on claims.';

-- ==============================================================================
-- HEALTHCARE ACTORS
-- ==============================================================================

CREATE TABLE patients (
    patient_id BIGINT GENERATED ALWAYS AS IDENTITY,
    -- In US Healthcare, the subscriber/member ID is critical for CI verification
    member_id VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_patients PRIMARY KEY (patient_id)
);

COMMENT ON TABLE patients IS 'The individuals receiving healthcare services. Kept lightweight to minimize PHI footprint, containing only what is needed for CI verification.';

CREATE TABLE providers (
    provider_id BIGINT GENERATED ALWAYS AS IDENTITY,
    -- National Provider Identifier is the universal key in US Healthcare
    npi VARCHAR(10) NOT NULL,
    provider_name VARCHAR(255) NOT NULL,
    -- e.g., 'INDIVIDUAL', 'GROUP'
    entity_type VARCHAR(50), 
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_providers PRIMARY KEY (provider_id),
    CONSTRAINT uq_providers_npi UNIQUE (npi)
);

COMMENT ON TABLE providers IS 'The billing or rendering physicians/entities that performed the service.';

CREATE TABLE facilities (
    facility_id BIGINT GENERATED ALWAYS AS IDENTITY,
    npi VARCHAR(10), -- Facilities often have NPIs, but it can occasionally be null depending on the billing structure
    facility_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_facilities PRIMARY KEY (facility_id)
);

COMMENT ON TABLE facilities IS 'Hospitals, clinics, or physical locations where the healthcare services were rendered.';