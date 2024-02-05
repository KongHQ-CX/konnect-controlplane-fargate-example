aws secretsmanager get-secret-value --secret-id ${KONNECT_PAT_SECRET_ARN} --output text --query 'SecretString'
