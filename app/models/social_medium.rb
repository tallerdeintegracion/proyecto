class SocialMedium < ActiveRecord::Base

	def searchMessages
		
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
		 url = urlImage(sku)
		 media = open(url)
		 client.update_with_media(message , media )

		##client.update(message)
				
	end
	def urlImage(sku)
		if(sku == '8')
			return 'public/images/FotoTrigo.jpg'
		end	
		if(sku == '31')
			return 'public/images/FotoLana.jpg'
		end	
		if(sku == '14')
			return 'public/images/FotoCebada.jpg'
		end	
		if(sku == '55')
			return 'public/images/FotoGalleta.jpg'
		end	
		if(sku == '49')
			return 'public/images/FotoLeche.jpg'
		end	
		if(sku == '6')
			return 'public/images/FotoCrema.jpeg'
		end	

		
	end
end
