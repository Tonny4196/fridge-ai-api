class UserBlueprint < Blueprinter::Base
  identifier :id

  fields :supabase_uid, :email, :name, :created_at, :updated_at
end