require 'bigdecimal'
require 'date'
class SocialMedium < ActiveRecord::Base

	def searchMessages
		
		require "bunny" # don't forget to put gem "bunny" in your Gemfile 
		require 'amqp'
		require 'json'
		#b = Bunny.new("amqp://lbhfijnx:fzM0TDPNOgDF4Gk8xc9ZqOgmNIywmiUG@hyena.rmq.cloudamqp.com/lbhfijnx")
		b = Bunny.new("amqp://uhmlacfa:ooQNlVdc5E2XbtenyuVRHVOLiyeNINQT@jellyfish.rmq.cloudamqp.com/uhmlacfa")
		b.start

		ch   = b.create_channel
		#result = ch.exchange_declare(exchange='promocion', type='fanout')

		q = ch.queue('ofertas', :auto_delete => true, :exclusive => false, :durable=>false)
		#puts "mensajes " + q.message_count.to_s
		messages = q.message_count

		while messages > 0

			msg = q.pop
			msg = msg[2].to_s
			msg_hash = JSON.parse(msg)
			
			#msg_hash = { "sku" => "8", "precio"  => "1200", "inicio" => "1466964673962", "fin" => "1466979073962", "publicar" => false, "codigo" => "hgdfsdsac" }
			
			sku = msg_hash['sku']
			precio = msg_hash['precio']
			inicio = msg_hash['inicio']
			fin = msg_hash['fin']	
			publicar = msg_hash['publicar']
			codigo = msg_hash['codigo']

			puts "el sku es " + sku 
			puts "precio " + precio.to_s
			puts "inicio " +  inicio.to_s
			puts "fin " + fin.to_s
			puts "publicar " + publicar.to_s
			puts "codigo " + codigo
			start = Time.strptime(inicio.to_s, '%Q').strftime("%Y-%m-%d %H:%M:%S")
			ending = Time.strptime(fin.to_s, '%Q').strftime("%Y-%m-%d %H:%M:%S")

			if(ourProduct(sku))

			  insertPromotionSpree(sku.to_i,precio,start,ending,codigo.to_s)
			end
			if(publicar.to_s == "true" )
				if (ourProduct(sku) == true)
					publishToSocialMedia(sku.to_s , precio.to_s, start.to_s, ending.to_s , codigo )
					puts "La promocion a sido publicada en redes sociales"
				end
			end

			messages = q.message_count

		end


		#{"sku":"25","precio":844,"inicio":1466558218578,"fin":1466572618578,"publicar":true,"codigo":"integrapromo41447"}

		ch.close
		b.stop 

	end

	def ourProduct(sku)
		if sku == "8"|| sku == "31" || sku == "14" || sku == "55" || sku == "49" || sku == "6"
			return true
		end	
		return false
		
	end
	def sendMessageUrl
		require "bunny" # don't forget to put gem "bunny" in your Gemfile 
		require 'amqp'
		#b = Bunny.new("amqp://lbhfijnx:fzM0TDPNOgDF4Gk8xc9ZqOgmNIywmiUG@hyena.rmq.cloudamqp.com/lbhfijnx")
		b = Bunny.new("amqp://uhmlacfa:ooQNlVdc5E2XbtenyuVRHVOLiyeNINQT@jellyfish.rmq.cloudamqp.com/uhmlacfa")
		
		#amqp://user:pass@host:10000/vhost
		#{}"amqp://lbhfijnx:fzM0TDPNOgDF4Gk8xc9ZqOgmNIywmiUG@hyena.rmq.cloudamqp.com:10000/lbhfijnx"
		puts "bunny " + b.to_s
		b.start # start a communication session with the amqp server
		puts b.to_s
		ch   = b.create_channel
		#result = ch.exchange_declare(exchange='promocion', type='fanout')
		e = ch.exchange("ofertas")
		e.publish('{"sku":"25","precio":844,"inicio":1466558218578,"fin":1466572618578,"publicar":true,"codigo":"integrapromo41447"}', :key => '')
		#q = ch.queue("develop_promociones", :durable => true)
		ch.close
	
		b.stop # close the connection


	end	



	def sendMessage
		
		require "bunny" # don't forget to put gem "bunny" in your Gemfile 
		require 'amqp'

		b = Bunny.new(:host => "hyena.rmq.cloudamqp.com", :vhost => "lbhfijnx", :user => "lbhfijnx", :password => "fzM0TDPNOgDF4Gk8xc9ZqOgmNIywmiUG")
		b.start # start a communication session with the amqp server
		puts b.to_s
		ch   = b.create_channel

		#result = ch.exchange_declare(exchange='promocion', type='fanout')
		e = ch.exchange("promociones")
		e.publish("Hello, everybody!", :key => 'promocion')
		#q = ch.queue("develop_promociones", :durable => true)
		ch.close
	
		b.stop # close the connection

		
	end

	def publishToSocialMedia(sku , precio, inicio , fin , codigo )
		skuDB = Sku.find_by(sku: sku)
		name = skuDB.descripcion
		publishTwitter(name, sku , precio, inicio , fin , codigo  )
		publishFacebook( name , sku , precio, inicio , fin , codigo )
	end

	def publishFacebook(name , sku , precio, inicio , fin , codigo  )
		require 'koala'

		#Non expiring token
 		page_token ='EAARmLDyuvpoBAAZCDBt3ZBRUAT6SlNPljwKOniZArCaZBJFsSOlJ6W1efpv3MWGSNQY5WNHwG0PfZBaeCPsQeZBzYq1viagaXIPv5tZB2usxknwCvGYZCJ1uuUH9kXZCiDRkT34ZC1XKQMtTZCPEgt9zYhq6J4M5rtZADA87vs6pEnQlroiQULVDldcm'
 		
		page_graph = Koala::Facebook::API.new(page_token)
		page_graph.get_connection('me', 'feed') # the page's wall

		message = makeMessage(name , sku , precio, inicio , fin , codigo  )
		url = urlImage(sku)
		Rails.logger.debug("url " + url )
		page_graph.put_wall_post(message , {    :name => "Nueva promocion",		
											    :link => "http://integra3.ing.puc.cl",
											    :picture =>"http://integra3.ing.puc.cl" + url 
											} ) # post as page, requires new publish_pages permission
													
	end	

	def makeMessage(name , sku , precio, inicio , fin , codigo  )
		message = "Promocion: " + name + " a " + precio.to_s + '$'
		message= message + "\n Desde: "+ inicio + " hasta el " + fin + "\n"
		message= message + "Codigo: " + codigo 
		return message
	end

	def publishTwitter(name , sku , precio, inicio , fin , codigo  )
		require 'twitter'
		  consumerKey='onWYs2Azpgf2yOrQiYNBMu4PD'
		  consumerSecret  = 'jUifCVSxU8kofI9CBqZmjagMTvsKpFxGqczOJepqQqfHt9dKOC'
		  accessToken ='743903466939158528-jU8LsyzKcZdtj5Q2R81kOriuHFOOd8d'
		  accessTokenSecret ='Qic0yEPtksRAHHnhg7Y2lOoHkJImGmZ63qiURfvDA5KrE'

		  client = Twitter::REST::Client.new do |config|
			  config.consumer_key        = consumerKey
			  config.consumer_secret     =  consumerSecret
			  config.access_token        = accessToken
			  config.access_token_secret =  accessTokenSecret	
		  end
		 message = "Promocion: " + name + " a " + precio.to_s + '$'
		 message= message + "\n Desde: "+ inicio + " hasta el " + fin + "\n"
		 message= message + "Codigo: " + codigo 
		 puts message	
		 url = 'public' + urlImage(sku)
		 media = open(url)
		 client.update_with_media(message , media )

		##client.update(message)
				
	end
	def urlImage(sku)
		if(sku == '8')
			return '/images/FotoTrigo.jpg'
		end	
		if(sku == '31')
			return '/images/FotoLana.jpg'
		end	
		if(sku == '14')
			return '/images/FotoCebada.jpg'
		end	
		if(sku == '55')
			return '/images/FotoGalleta.jpg'
		end	
		if(sku == '49')
			return '/images/FotoLeche.jpg'
		end	
		if(sku == '6')
			return '/images/FotoCrema.jpeg'
		end		
	end

	def insertPromotionSpree(sku,precio,inicio,fin,codigo)

		#puts Spree::Calculator.find_by(type:"Spree::Calculator::ProductWithOptionValueCalculator").to_json.to_s
		promocion = Spree::Promotion.find_or_create_by(description: "Promocion" ,expires_at: fin ,starts_at: inicio ,name:"Promocion del SKU "+sku.to_s,type: nil,usage_limit:nil,match_policy:"all", code: codigo, advertise: 0, path: nil, created_at: "",updated_at: "",promotion_category_id: nil )
		action = Spree::PromotionAction.create(promotion_id: promocion[:id],position:nil,type: "Spree::Promotion::Actions::CreateAdjustment",deleted_at: nil)
		inv = Inventario.new
		pref = { :product_price => BigDecimal.new(precio), :idProducto => inv.SKUToId(sku)} ##cambiar
		
		Spree::Calculator.create(type: "Spree::Calculator::ProductWithOptionValueCalculator",calculable_id: action[:id] ,calculable_type: "Spree::PromotionAction", created_at: "",updated_at:"", preferences: pref) ##Faltan los preferences

		toDelete = Spree::Calculator.find_by(type: "Spree::Calculator::FlatPercentItemTotal",calculable_id: action[:id])

		toDelete.destroy
	end
end
