class InventarioController < ApplicationController
 	

#6	Crema	Producto procesado	3	Lts	  2,402 	  30 	0.979
#8	Trigo	Materia prima	3	Kg	  1,313 	  100 	0.784
#14	Cebada	Materia prima	3	Kg	  696 	  1,750 	1.355
#31	Lana	Materia prima	3	Mts	  1,434 	  960 	3.449
#49	Leche Descremada	Producto procesado	3	Lts	  1,459 	  200 	4.281
#55	Galletas Integrales	Producto procesado	3	Kg	  2,284 	  950 	3.955

  
  def self.run
  
  inv = Inventario.new
  inv.run
  end

end  

	