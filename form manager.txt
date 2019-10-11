form manager

table - fae_form_managers
fields - model_name, fields, created_at, updated_at

integrate into fae changes

make fae installer to add to existing apps

doc
install - rake fae:install_form_manager
copies migration and migrates db

config fae uses form manager = true

issues
[] nested forms are generated - have to manually add manage form buttons and empty helper els