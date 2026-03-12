#!/bin/bash
# ==============================================================================
# Script para inicializar Chatwoot y crear un usuario administrador por defecto
# ==============================================================================

echo "⏳ Esperando a que el contenedor de chatwoot_web esté listo..."
sleep 10

echo "🛠️  Ejecutando migraciones de base de datos de Chatwoot..."
docker-compose exec -T chatwoot_web bundle exec rake db:chatwoot_prepare

echo "👤 Creando cuenta y usuario administrador..."
docker-compose exec -T chatwoot_web bundle exec rails runner "
  account = Account.find_by(name: 'Taller Mecanico') || Account.create!(name: 'Taller Mecanico')
  user = User.find_by(email: 'admin@taller.local')
  unless user
    user = User.create!(
      email: 'admin@taller.local',
      password: 'Password123!',
      password_confirmation: 'Password123!',
      name: 'Super Admin',
      role: :administrator,
      confirmed_at: Time.now
    )
    AccountUser.create!(account: account, user: user, role: :administrator)
    puts '✅ Usuario administrador creado: admin@taller.local / Password123!'
  else
    puts 'ℹ️ El usuario administrador ya existe.'
  end
"

echo "🎉 ¡Configuración de Chatwoot completada!"
