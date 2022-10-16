require 'json'
require 'jwt'
require 'sinatra/base'
require 'date'

class JwtAuth

    def initialize app
      @app = app
    end
  
    def call env
      begin
        options = { algorithm: 'HS256', iss: ENV['JWT_ISSUER'] }
        bearer = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
        payload, header = JWT.decode bearer, ENV['JWT_SECRET'], true, options 
        env[:user] = payload['user']
  
        @app.call env
      rescue JWT::ExpiredSignature
        [403, { 'Content-Type' => 'text/plain' }, ['El token expiró.']]
      rescue JWT::InvalidIssuerError
        [403, { 'Content-Type' => 'text/plain' }, ['El token no tienen un emisor válido.']]
      rescue JWT::InvalidIatError
        [403, { 'Content-Type' => 'text/plain' }, ['El token no tiene un tiempo de emisión válido.']]
      rescue JWT::DecodeError
        [401, { 'Content-Type' => 'text/plain' }, ['Se tiene que enviar un token.']]
      end
    end
  
  end

class Api < Sinatra::Base

    use JwtAuth
    
    def initialize
      super
      @locations = ['Amsterdam', 'Paris', 'Barcelona', 'Bogotá', 'Lima', 'Londres', 'Montevideo', 'Kioto', 'Seúl', 'El Cairo', 'Dakar']
    end
    
    post '/search' do
      for_date = params[:for_date]
      quantity = params[:quantity].to_i
      name = params[:name]
      caso = params[:caso].to_i
      if name.nil? || for_date.nil? || quantity.nil?
        return 'Uso incorrecto de la API, leer la documentacion en: URL no hay URL'
      end
      for_date = Date.strptime(for_date, '%d-%m-%Y')
      if quantity < 1
        return 'La cantidad de material debe ser un número positivo'
      end
      if for_date < Date.today
        return 'La fecha debe ser mayor al día de hoy'       
      end
      arr = []
      locaciones = @locations.sample(6)
      precio = rand(9999)
      case caso
      when 1 #Quiero que haya material para la fecha solicitada en la cantidad solicitada
        arr.push({ fecha: for_date, material: name, cantidad: quantity })
        arr.push({ id: rand(9999), ubicacion: @locations.sample, precio: precio.to_s + 'U$D'})
      when 2 #Quiero que haya varios provedores  
        cantidad = rand(2..5)
        arr.push({ fecha: for_date, material: name, cantidad: quantity })
        for i in 0...cantidad do
          arr.push({ id: rand(9999), ubicacion: locaciones[i], precio: (precio + rand(-100..100)).to_s + 'U$D'})
        end
      else #Quiero que no haya materiales para esa fecha y envié n, mas cercanas a esa fecha
        cantidad = rand 2..5
        days = rand 2..10
        arr.push({ fecha: for_date.next_day(days), material: name, cantidad: quantity })
        for i in 0...cantidad do
          arr.push({ id: rand(9999), ubicacion: locaciones[i], precio: (precio + rand(-100..100)).to_s + 'U$D'})
        end
      end
      arr.to_json
    end
      
    post '/reserve' do
      id = params[:id]
      if id.nil?
        return 'No se envió el id de la reserva'
      end
      id = id.to_i
      if id < 1
        return 'No se puede realizar una reserva con ese id'
      end
      "Se realizó la reserva con identificador: #{id}"  
    end

    post '/cancel' do
      id = params[:id]
      if id.nil?
        return 'No se envió el id de la reserva a cancelar'
      end
      id = id.to_i
      if id < 1
        return 'No existe una reserva para ese id'
      end
      "Se canceló la reserva con identificador: #{id}"  
    end

    not_found do
      'Uso incorrecto de la API, ingresa en: URL para ver la documentación'
    end
  
  end
  
  class Public < Sinatra::Base
  
    def initialize
      super
  
      @logins = {
        "susana.garcia": 'bpm'
      }
    end

    post '/login' do
      username = params[:username]
      password = params[:password]
      if username.nil? || password.nil?
        'No se envió el usuario o la contraseña'  
      else  
        if @logins[username.to_sym] == password
          content_type :json
          { token: token(username) }.to_json
        else
          [401, { 'Content-Type' => 'text/plain' }, 'Usuario o contraseña no válidos.']
        end
      end
    end
  
    not_found do
      'Uso incorrecto de la API, ingresa en: URL para ver la documentación'
    end
  
    private

    def token username
      JWT.encode payload(username), ENV['JWT_SECRET'], 'HS256'
    end
    
    def payload username
      {
        exp: Time.now.to_i + 7500,
        iat: Time.now.to_i,
        iss: ENV['JWT_ISSUER'],
        user: {
          username: username
        }
      }
    end
  
  end