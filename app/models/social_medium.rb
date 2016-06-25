class SocialMedium < ActiveRecord::Base

	def searchMessages
		
		require "bunny" # don't forget to put gem "bunny" in your Gemfile 
		require 'amqp'
		require 'json'
		b = Bunny.new("amqp://lbhfijnx:fzM0TDPNOgDF4Gk8xc9ZqOgmNIywmiUG@hyena.rmq.cloudamqp.com/lbhfijnx")
		b.start

		ch   = b.create_channel
		#result = ch.exchange_declare(exchange='promocion', type='fanout')

		q = ch.queue('ofertas', :auto_delete => true, :exclusive => false, :durable=>false)
		#puts "mensajes " + q.message_count.to_s
		messages = q.message_count

		while messages > 0

			msg = q.pop
			msg_hash = JSON.parse(msg)
			sku = msg_hash['sku']
			precio = msg_hash['precio']
			inicio = msg_hash['inicio']
			publicar = msg_hash['publicar']
			codigo = msg_hash['codigo']
			
			puts "el sku es " + sku 



			messages = q.message_count
		end


		#{"sku":"25","precio":844,"inicio":1466558218578,"fin":1466572618578,"publicar":true,"codigo":"integrapromo41447"}

		ch.close
		b.stop 

	end


	def sendMessageUrl
		require "bunny" # don't forget to put gem "bunny" in your Gemfile 
		require 'amqp'
		b = Bunny.new("amqp://lbhfijnx:fzM0TDPNOgDF4Gk8xc9ZqOgmNIywmiUG@hyena.rmq.cloudamqp.com/lbhfijnx")
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
 		page_token ='EAARmLDyuvpoBADZCli0Lm4pTeIZC9CMZAHGFcCcoHcGYZCK26aW3swdpL2lb3vkj0b4dIGj30SiJLc02qMLXRlwmL7oO6LYZC5Piiq0AOe7FLBAdQcbcGScC6Ve8WJ4gUNdsr9oFqZA3BrFPwUhOP2i7rzaN6dIbelsiuSuTZCFInuxQ3YjWHxu3koBr58eEIwZD'
 	

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
end
