CREATE TABLE claims (
    -- Surrogate Primary Key
    claim_id BIGINT GENERATED ALWAYS AS IDENTITY,
    
    -- Foreign Keys to Core Entities
    client_id BIGINT NOT NULL,
    payer_id BIGINT NOT NULL,
    patient_id BIGINT NOT NULL,
    provider_id BIGINT NOT NULL,
    facility_id BIGINT,
    
    -- External Identifiers
    claim_control_number VARCHAR(100) NOT NULL,
    
    -- Claim Metadata
    claim_type VARCHAR(50) NOT NULL,
    encounter_type VARCHAR(50) NOT NULL,
    workflow_status VARCHAR(50) NOT NULL DEFAULT 'RECEIVED',
    
    -- Temporal Encounter Data
    service_start_date DATE NOT NULL,
    service_end_date DATE NOT NULL,
    
    -- Financial Context
    total_billed_amount NUMERIC(15, 2) NOT NULL,
    
    -- Audit Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_claims PRIMARY KEY (claim_id),
    
    -- Foreign Keys
    CONSTRAINT fk_claims_client FOREIGN KEY (client_id) 
        REFERENCES clients(client_id) ON DELETE RESTRICT,
        
    CONSTRAINT fk_claims_payer FOREIGN KEY (payer_id) 
        REFERENCES payers(payer_id) ON DELETE RESTRICT,
        
    CONSTRAINT fk_claims_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id) ON DELETE RESTRICT,
        
    CONSTRAINT fk_claims_provider FOREIGN KEY (provider_id) 
        REFERENCES providers(provider_id) ON DELETE RESTRICT,
        
    CONSTRAINT fk_claims_facility FOREIGN KEY (facility_id) 
        REFERENCES facilities(facility_id) ON DELETE RESTRICT,
        
    -- Data Integrity: Ensure a client cannot ingest the same claim twice
    CONSTRAINT uq_claims_client_ccn UNIQUE (client_id, claim_control_number),
    
    -- Business Logic Checks
    CONSTRAINT chk_claims_service_dates CHECK (service_end_date >= service_start_date),
    CONSTRAINT chk_claims_billed_amount CHECK (total_billed_amount >= 0),
    
    -- Standard Industry Classifications (Enforced at DB level, mapped at App level)
    CONSTRAINT chk_claims_type CHECK (
        claim_type IN ('PROFESSIONAL', 'INSTITUTIONAL')
    ),
    CONSTRAINT chk_claims_encounter_type CHECK (
        encounter_type IN ('INPATIENT', 'OUTPATIENT', 'EMERGENCY', 'OFFICE', 'OBSERVATION')
    )
);

-- Table Comment
COMMENT ON TABLE claims IS 'The root entity representing a healthcare claim entering the investigation platform. Contains top-level metadata, dates, and routing information. Does not include adjudication or payment processing logic.';

-- Column Comments
COMMENT ON COLUMN claims.claim_control_number IS 'The external unique identifier (ICN/DCN) provided by the client/payer. Required to map clinical decisions back to the source system.';
COMMENT ON COLUMN claims.claim_type IS 'The standard industry billing format (e.g., PROFESSIONAL for CMS-1500, INSTITUTIONAL for UB-04). Dictates AI coding rules. Display logic handles operational terminology mapping.';
COMMENT ON COLUMN claims.encounter_type IS 'The clinical setting where care occurred (e.g., INPATIENT, OUTPATIENT, OFFICE). Dictates which medical records to look for and which clinical guidelines apply.';
COMMENT ON COLUMN claims.workflow_status IS 'The current macro-state of the claim investigation (e.g., RECEIVED, IN_REVIEW, COMPLETED).';
COMMENT ON COLUMN claims.service_start_date IS 'The earliest date of service found on the claim header. Used by the investigator to bracket the timeline.';
COMMENT ON COLUMN claims.service_end_date IS 'The latest date of service found on the claim header.';
COMMENT ON COLUMN claims.total_billed_amount IS 'The aggregate billed amount across all lines. Used exclusively for triage, prioritization, and queue routing.';