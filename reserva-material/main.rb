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
      ubicaciones = ['Estados Unidos - Chicago', 'España - Barcelona', 'Colombia - Bogotá', 'Perú - Lima', 'Uruguay - Montevideo']
      proveedores = ['B-Cycle', 'Amazon', 'Recycle company', 'Eco recycle', 'Reciclar SA']
      coordenadas = [[41.8443535947532, -87.75115600228746], [41.31472243655048, 2.0814067069359576], [4.67222501691664, -74.10642898351165], [-12.068907651606178, -77.07086384139262], [-34.851229958045046, -56.21378540926756]]
      @proveedores = []
      for i in 0...5 do
        @proveedores.push({ id: 1000+i, proveedor: proveedores[i], ubicacion: ubicaciones[i], coordenadas: coordenadas[i] }) 
      end
    end
    
    post '/search' do
      #Obetener los parámetros
      fecha = params[:fecha]
      cantidad = params[:cantidad].to_i
      material = params[:material]
      caso = params[:caso].to_i
      #Chequear los parámetros
      if material.nil? || fecha.nil? || cantidad.nil?
        return 'Uso incorrecto de la API, leer la documentacion en: https://github.com/ucabrera/DSSD-reserva/tree/main/reserva-material '
      end
      fecha = Date.strptime(fecha, '%d-%m-%Y')
      if cantidad < 1
        return 'La cantidad de material debe ser un número positivo'
      end
      if fecha < Date.today
        return 'La fecha debe ser mayor al día de hoy'       
      end
      #Algunas variables
      arr = []
      precio = rand(500..9999)
      cant = rand(1..5) #Cantidad de proveedores a retornar
      if caso != 1
        fecha = fecha.next_day(rand 1..15)
      end
      arr.push({ fecha: fecha, material: material, cantidad: cantidad })
      @proveedores.shuffle!
      for i in 0...cant do
          proveedor = @proveedores[i]
          proveedor['precio'] = (precio + rand(-150..150)).to_s + 'U$D'
          arr.push(proveedor)
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
      'Uso incorrecto de la API, ingresa en: https://github.com/ucabrera/DSSD-reserva/tree/main/reserva-material para ver la documentación'
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