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
        [401, { 'Content-Type' => 'text/plain' }, ['El token no es válido.']]
      end
    end
  
  end

class Api < Sinatra::Base

    use JwtAuth
    
    def initialize
      super
      espacios = ['Francia - París', 'Japón - Kioto', 'Brasil - San Pablo', 'Egipto - El Cairo', 'Senegal - Dakar']
      @ubicaciones = []
      for i in 0...5 do
        @ubicaciones.push({ id: 2000 + i, ubicacion: espacios[i] }) 
      end
    end
    
    post '/search' do
      fecha = params[:fecha]
      dias = params[:dias]
      caso = params[:caso].to_i
      if fecha.nil? && dias.nil?
        return 'No se envió la fecha a buscar y la cantidad de días'
      end
      if fecha.nil?
        return 'No se envió la fecha a buscar'
      end
      if dias.nil?
        return 'No se envió la cantidad de días'
      end
      dias = params[:dias].to_i
      fecha = Date.strptime(fecha, '%d-%m-%Y')
      if dias < 1
        return 'La cantidad de días debe ser un número positivo'
      end
      if fecha < Date.today
        return 'La fecha a buscar debe ser mayor al día de hoy'       
      end
      arr = []
      if caso != 1 
        fecha = fecha.next_day(rand 2..30)
      end
      arr.push({ fecha: fecha })
      cant = rand(1..5)
      costo = dias * 85 + 1000 + (rand 10000)
      @ubicaciones.shuffle!
      for i in 0...cant do
        ubicacion = @ubicaciones[i]
        ubicacion['costo'] = (costo + rand(-250..250)).to_s + 'US$'
        arr.push(ubicacion)
      end
      arr.to_json
    end
      
    post '/reserve' do
      id = params[:id]
      if id.nil?
        return 'No se envió el id de la reserva'
      end
      id = id.to_i
      if id < 2000
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
      if id < 2000
        return 'No existe una reserva para ese id'
      end
      "Se canceló la reserva con identificador: #{id}"  
    end

    not_found do
      'Uso incorrecto de la API, ingresa en: https://github.com/ucabrera/DSSD-reserva/tree/main/reserva-espacio para ver la documentación'
    end
  
  end
  
  class Public < Sinatra::Base
  
    def initialize
      super
    end

    post '/login' do
      username = params[:username]
      password = params[:password]
      if username.nil? || password.nil?
        'No se envió el usuario o la contraseña'  
      else  
        if username == 'wwglasses' && password == 'wwglasses'
          content_type :json
          { token: token(username) }.to_json
        else
          [401, { 'Content-Type' => 'text/plain' }, 'Usuario o contraseña no válidos.']
        end
      end
    end
  
    get '/' do
      redirect '/index.html'
    end
    
    not_found do
      'Uso incorrecto de la API, ingresa en: https://github.com/ucabrera/DSSD-reserva para ver la documentación'
    end
  
    private

    def token username
      JWT.encode payload(username), ENV['JWT_SECRET'], 'HS256'
    end
    
    def payload username
      {
        exp: Time.now.to_i + 1600,
        iat: Time.now.to_i,
        iss: ENV['JWT_ISSUER'],
        user: {
          username: username
        }
      }
    end
  
  end