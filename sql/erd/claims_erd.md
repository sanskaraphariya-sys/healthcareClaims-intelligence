```mermaid
erDiagram

    CLAIM ||--o{ CLAIM_LINE : contains
    CLAIM ||--o{ MEDICAL_RECORD : includes
    CLAIM ||--o{ REVIEW : undergoes
    REVIEW ||--o{ APPEAL : may_generate
    CLAIM_LINE ||--o{ EVIDENCE : supported_by
```