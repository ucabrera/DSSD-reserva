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
      #options = { algorithm: 'HS256', iss: ENV['JWT_ISSUER'] }
      options = { algorithm: 'HS256', iss: 'JWT_ISSUER' }
      bearer = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
      #payload, header = JWT.decode bearer, ENV['JWT_SECRET'], true, options 
      payload, header = JWT.decode bearer, 'JWT_SECRET', true, options 
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
      @proveedores = {
        "id": 1001,
        "nombre": "GARZON Y CIA.",
        "tarifa": 15000,
        "direccion": "Av. Belgrano 164 1 27",
        "ciudad": "Alta Gracia",
        "provincia": "Córdoba",
        "pais": "Argentina",
        "correo": "garzon@empresa.com",
        "materiales": ["Vidrio reciclado", "Plástico reciclado", "Madera"]},
        
        
        {
        "id": 1002,
        "nombre": "SM INDUSTRIAL SRL",
        "tarifa": 12000,
        "direccion": "Av. Facundo Zuviría 5842",
        "ciudad": "Santa Fe",
        "provincia": "Santa Fe",
        "pais": "Argentina",
        "correo": "smindustrial@empresa.com",
        "materiales": ["Corcho", "Aluminio", "Acetato de madera reciclada"]},
        
        {
        "id": 1003,
        "nombre": "MAAS SRL",
        "tarifa": 17000,
        "direccion": "Av. Chile 245",
        "ciudad": "Río de Janeiro",
        "provincia": "Río de Janeiro",
        "pais": "Brasil",
        "correo": "maas@empresa.com",
        "materiales": ["Bambú", "Corcho", "Aluminio"]},
        
        {
        "id": 1004,
        "nombre": "DOMINA S.A.",
        "tarifa": 14000,
        "direccion": "Cl. 54 # 57-60, La Candelaria",
        "ciudad": "Medellín",
        "provincia": "Antioquia",
        "pais": "Colombia",
        "correo": "domina@empresa.com",
        "materiales": ["Vidrio reciclado", "Plástico reciclado", "Bambú"]},
        
        {
        "id": 1005,
        "nombre": "EMPRESAS CMPC S.A.",
        "tarifa": 12500,
        "direccion": "Agustinas 1343",
        "ciudad": "Santiago de Chile",
        "provincia": "Región Metropolitana",
        "pais": "Chile",
        "correo": "cmpc@empresa.com",
        "materiales": ["Aluminio", "Acetato de fibra de algodón", "Acetato de madera reciclada"]}
    end
    
   
    get '/materials' do
      @proveedores.to_json
    end
      
    post '/reserve' do
      id = params[:id]
      if id.nil?
        return 'No se envió el id de la reserva'
      end
      id = id.to_i
      if id < 1000
        return 'No se puede realizar una reserva con ese id'
      end
      "Se realizó la reserva con identificador: #{id}"  
    end

    delete '/cancel' do
      id = params[:id]
      if id.nil?
        return 'No se envió el id de la reserva a cancelar'
      end
      id = id.to_i
      if id < 1000
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

    get '/' do
      redirect '/index.html'
    end
  
    not_found do
      'Uso incorrecto de la API, ingresa en: https://github.com/ucabrera/DSSD-reserva para ver la documentación'
    end
  
    private

    def token username
      #JWT.encode payload(username), ENV['JWT_SECRET'], 'HS256'
      JWT.encode payload(username), 'JWT_SECRET', 'HS256' 
    end
    
    def payload username
      {
        exp: Time.now.to_i + 1600,
        iat: Time.now.to_i,
        #iss: ENV['JWT_ISSUER'],
        iss: 'JWT_ISSUER',
        user: {
          username: username
        }
      }
    end
  
  end