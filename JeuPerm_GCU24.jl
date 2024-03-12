### A Pluto.jl notebook ###
# v0.19.13

using Markdown
using InteractiveUtils

# ╔═╡ c7e31109-3c17-4880-b870-6dd45eb29aa1
begin
	using Pkg
	cd("/Users/alexandredemerode/Desktop/Jeu Perm - GCU 2024/GitHub files")
	Pkg.activate(pwd())
	using NativeSVG
	using PlutoUI
	using SimpleDrawing
	using Plots
	using PrettyTables
end

# ╔═╡ b9b43e1a-fac4-403c-9bd7-02e9126f0ca8
md" # JEU PERMANENT GCU 2024
###### Baden Powell Belgian Lonescouts"

# ╔═╡ 27d48cc9-69bb-49f1-8290-ac821e6f77d9
md" ## Partie A - Fonctions du jeu"

# ╔═╡ 9462050f-92ca-4c33-b1f8-afcc80ede3cf
md" ### 1. Définition des structures"

# ╔═╡ f29c16f1-b8a2-41d4-986b-4b83dec9032d
mutable struct Territoire
	CaseID::Int
	Troupe::String
	Soldats::Float64
	Bateaux::Float64
	Minerais::Float64
	Blé::Float64
	Bois::Float64
	Pierre::Float64
	Ferme::Bool
	Caserne::Bool
	Port::Bool
	IsFluvial::Bool
	IsCoast::Bool
	IsMountains::Bool
	#Neighbours::Array
end

# ╔═╡ 61fbec2c-1003-4ccf-a588-0f5b927226f1
mutable struct Troupe
	Nom::String
	Territoires::Float64
	Soldats::Float64
	Bateaux::Float64
	Minerais::Float64
	Blé::Float64
	Bois::Float64
	Pierre::Float64
end

# ╔═╡ 4f4b516e-00c6-4dc3-aee3-7fb8c1a1b8cf
md"### Génération du monde (fixe) "

# ╔═╡ 2bebe9c0-b5af-4336-825a-9add6581d21d
# ENTRER ICI LES CARACTERISTIQUES FIXES DU JEU
begin
	const Coast = [3,4,8] #Liste des territoires côtiers
	const Fluv = [1,2,9] #Liste des territoires en bordure de fleuve
	const Mount = [5,8,9] #Liste des territoires montagneux
	const Farm_Cost = [10 10 0 0] #Ordre : Bois, Pierre, Blé, Minerais
	const Cas_Cost = [15 15 0 0]
	const Boat_Cost = [20 0 0 10]
	const Sold_Cost = [0 0 0 10]
	const SoldEntr_Cost = [0 0 10 0]
	const Port_Cost = [50 50 0 0]
end

# ╔═╡ 2fa4706b-f1ca-4fa0-8568-b0512936d8b2
function Fluv_Terr(World_Mat,Terr_Mat)
	for Terr in World_Mat
		if Terr.CaseID in Terr_Mat
			Terr.IsFluvial = true
		end
	end
end

# ╔═╡ 000d6c33-dc9f-4ddb-8439-20d1a7a98d82
function Coast_Terr(World_Mat,Terr_Mat)
	for Terr in World_Mat
		if Terr.CaseID in Terr_Mat
			Terr.IsCoast = true
		end
	end
end

# ╔═╡ 5ebd7c4e-6dba-44dc-b4fe-8fcaf4f5b09c
function Mount_Terr(World_Mat,Terr_Mat)
	for Terr in World_Mat
		if Terr.CaseID in Terr_Mat
			Terr.IsMountains = true
		end
	end
end

# ╔═╡ 0b8cd34c-02e7-4559-a687-bc1a8f020ddf
function World_Generator(Nbr_Terr)
	World_Matrix = []::Any
	for i in 1:Nbr_Terr
		push!(World_Matrix,Territoire(i,"Autochtones",0,0,0,0,0,0,false,false,false,false,false,false))
	end
	Coast_Terr(World_Matrix,Coast)
	Fluv_Terr(World_Matrix,Fluv)
	Mount_Terr(World_Matrix,Mount)
	return World_Matrix
end

# ╔═╡ 12022262-301a-48ec-ac21-639cf1f0b06b
const Troupe_Names = ["Archers", "Hardis", "Paladins","Lanciers","Gueux","Preux","Vaillants","Chevaliers","Templiers","Servants","Autochtones"]

# ╔═╡ 933a08ef-df41-4f9d-b755-2f467dbad556
function Actors_Generators()
	Actors = []::Any
	for element in Troupe_Names
		push!(Actors,Troupe(element,0,0,0,0,0,0,0))
	end
	return Actors
end

# ╔═╡ c74e5a5a-9958-4fbc-a116-b21b596534a7
World = World_Generator(175)

# ╔═╡ abd800af-4f8f-48bb-9588-f43c75957605
function Temporary_WorldFiller(World_Matrix)
	for Terr in World_Matrix
		Terr.Minerais=30*rand(1)[1]
		Terr.Blé=30*rand(1)[1]
		Terr.Bois=30*rand(1)[1]
		Terr.Pierre=30*rand(1)[1]
		Terr.Soldats = round(10*rand(1)[1])
	end

	for i in 1:Int(round(size(World)[1]/5))
		World_Matrix[i].Troupe = rand(Troupe_Names)
	end
	return World
end

# ╔═╡ 37269211-df0f-4dee-8c09-53af7cad3ba8
Temporary_WorldFiller(World)

# ╔═╡ bc77685a-b141-453c-b489-b93ab6db8d40
Troupes = Actors_Generators()

# ╔═╡ 4782e4f3-a8ba-459e-8668-e82330ae7b0d
function Display_MilInfo(World_Matrix,Actors_Matrix,Troupe::String)
	#Data collection
	Trr_Count = 0
	Sld_Count = 0
	Bot_Count = 0
	Min_Count = 0
	Blé_Count = 0
	Wod_Count = 0
	Stn_Count = 0
	for Terr in World_Matrix
		if Terr.Troupe == Troupe
			Trr_Count += 1
			Sld_Count += Terr.Soldats
			Bot_Count += Terr.Bateaux
			#Min_Count += Terr.Minerais
			#Blé_Count += Terr.Blé
			#Wod_Count += Terr.Bois
			#Stn_Count += Terr.Pierre
		end
	end
	#Filling the Actors matrix
	for element in Actors_Matrix
		if element.Nom == Troupe
			element.Territoires = Trr_Count
			element.Soldats = Sld_Count
			element.Bateaux = Bot_Count
			##element.Minerais = Min_Count
			#element.Blé = Blé_Count
			#element.Bois = Wod_Count
			#element.Pierre = Stn_Count
			return element
		end
	end
end	

# ╔═╡ 51fdab25-7c05-432d-a388-7949cfeddb3e
function Properties(World_Matrix,Troupe::String)
	Possessions = []
	for Terr in World_Matrix
		if Terr.Troupe == Troupe
			push!(Possessions, Terr.CaseID)
		end
	end
	return Possessions
end

# ╔═╡ 6ed6bcf1-4b61-4adf-ae18-22959bac3f1f
function Find_Troup(Troupe::String, Actors_Matrix)
	Trp = []::Any
	for element in Actors_Matrix
		if element.Nom == Troupe
			push!(Trp, element)
		end
	end
	return Trp[1]
end

# ╔═╡ 92d24137-9c9c-4b0c-b335-75dcf2b9b36a
Find_Troup("Servants",Troupes)

# ╔═╡ df926619-dc2c-48ce-80bd-5481bfe8b74a
P = Properties(World,"Archers")

# ╔═╡ 49d6deec-8929-4e17-9ba7-a23cec4de568
function Actualise_Fortuna(World_Matrix,Actors_Matrix,Troupe::String,Action::String)
	Prop = Properties(World_Matrix,Troupe)
	Troup_Struct = Find_Troup(Troupe,Actors_Matrix)
	if Action == "New_turn"
		#Revenus générés par les territoires à chaque tour
		for i = 1:size(Prop)[1]
			CaseID = Prop[i]
			Terr = World_Matrix[CaseID]
			Troup_Struct.Bois += Terr.Bois
			Troup_Struct.Pierre += Terr.Pierre
			Troup_Struct.Blé += Terr.Blé
			Troup_Struct.Minerais += Terr.Minerais
		end
	end	
end
#A TERMINER

# ╔═╡ 32a45743-7e12-4b34-aa9f-8feebc5433a9
Actualise_Fortuna(World,Troupes,"Hardis","New_turn")

# ╔═╡ d7683354-8f06-4c61-80ff-64b7a171c850
Display_MilInfo(World,Troupes,"Autochtones")

# ╔═╡ 25f01e6a-303f-45e9-b860-d53cb12c2525
function Update_LonesSituation(World_Matrix,Actors_Matrix)
	# Update all troupes stats
	for troupe in Troupe_Names
		Display_MilInfo(World_Matrix,Actors_Matrix,troupe)
	end
	LonesSit = Actors_Matrix

	#Translate the results in a matrix form
	header = ["TROUPES","Territoires", "Soldats", "Bateaux","Minerais","Blé","Bois","Pierres"]
	data = ones(11,7)
	for i in 1:11
		data[i,1] = data[i,1]*LonesSit[i].Territoires*data[i,1]
		data[i,2] = data[i,2]*LonesSit[i].Soldats*data[i,2]
		data[i,3] = data[i,3]*LonesSit[i].Bateaux*data[i,3]
		data[i,4] = data[i,4]*round(LonesSit[i].Minerais)*data[i,4]
		data[i,5] = data[i,5]*round(LonesSit[i].Blé)*data[i,5]
		data[i,6] = data[i,6]*round(LonesSit[i].Bois)*data[i,6]
		data[i,7] = data[i,7]*round(LonesSit[i].Pierre)*data[i,7]
	end
	data = [Troupe_Names data]

	#Display the data in a pretty table
	with_terminal() do
		pretty_table(data,body_hlines = collect(1:11);header = header)
	end
end

# ╔═╡ bcef50dc-78cf-4fe0-97fd-9810dc1fb5ab
Update_LonesSituation(World,Troupes)

# ╔═╡ 82ce8603-027a-4197-8d9e-d6c471e416ed
function Terr_Info(World_Matrix,Territoire::Int)
	Terr =  World_Matrix[Territoire]
	Propriétaire = uppercase(Terr.Troupe)
	Soldats = Terr.Soldats
	Bateaux = Terr.Bateaux
	Minerais = round(Terr.Minerais)
	Blé = round(Terr.Blé)
	Bois = round(Terr.Bois)
	Pierre = round(Terr.Pierre)
	Ferme = "Non"
	Caserne = "Non"
	Port = "Non"
	if Terr.Ferme == true
		Ferme = "Oui"
	else
		Ferme = "Non"
	end
	if Terr.Caserne == true
		Caserne = "Oui"
	else
		Caserne = "Non"
	end
	if Terr.Port == true
		Port = "Oui"
	else
		Port = "Non"
	end	
	with_terminal() do
		println("Territoire n°$Territoire -- $Propriétaire")
		println("--------------------------------")
		#println("Propriétaire : $Propriétaire")
		println("Nombre de soldats : $Soldats")
		println("Nombre de bateaux : $Bateaux")
		println("Richesse en minerais : $Minerais")
		println("Richesse en Blé : $Blé")
		println("Richesse en Bois : $Bois")
		println("Richesse en Pierre : $Pierre")
		println("Présence d'une Ferme : $Ferme")
		println("Présence d'une Caserne : $Caserne")
		println("Présence d'un port : $Port")
	end
end

# ╔═╡ ffe405e7-33f9-46c2-9436-cecb729fefc3
Terr_Info(World,2)

# ╔═╡ f2a72f90-7841-4ccd-a09d-2c94f54476e8
function Add_Entity(World_Matrix,Actors_Matrix,Terr::Territoire, Entity::String)
	Actor = Terr.Troupe
	Data = Display_TrpInfo(World_Matrix,Actors_Matrix,Actor::String)
	Cost = []
	if Entity == "Ferme"
		Cost = Cas_Cost
	elseif Entity == "Caserne"
		Cost = Cas_Cost
	elseif Entity == "Port"
		Cost = Port_Cost
	elseif Entity == "Bateau"
		Cost = Boat_Cost
	elseif Entity == "Soldat"
		Cost = Sold_Cost
	end
end
# A TERMINER

# ╔═╡ Cell order:
# ╠═c7e31109-3c17-4880-b870-6dd45eb29aa1
# ╟─b9b43e1a-fac4-403c-9bd7-02e9126f0ca8
# ╟─27d48cc9-69bb-49f1-8290-ac821e6f77d9
# ╟─9462050f-92ca-4c33-b1f8-afcc80ede3cf
# ╠═f29c16f1-b8a2-41d4-986b-4b83dec9032d
# ╠═61fbec2c-1003-4ccf-a588-0f5b927226f1
# ╟─4f4b516e-00c6-4dc3-aee3-7fb8c1a1b8cf
# ╠═2bebe9c0-b5af-4336-825a-9add6581d21d
# ╠═2fa4706b-f1ca-4fa0-8568-b0512936d8b2
# ╠═000d6c33-dc9f-4ddb-8439-20d1a7a98d82
# ╠═5ebd7c4e-6dba-44dc-b4fe-8fcaf4f5b09c
# ╠═0b8cd34c-02e7-4559-a687-bc1a8f020ddf
# ╠═12022262-301a-48ec-ac21-639cf1f0b06b
# ╠═933a08ef-df41-4f9d-b755-2f467dbad556
# ╠═abd800af-4f8f-48bb-9588-f43c75957605
# ╠═c74e5a5a-9958-4fbc-a116-b21b596534a7
# ╠═37269211-df0f-4dee-8c09-53af7cad3ba8
# ╠═bc77685a-b141-453c-b489-b93ab6db8d40
# ╠═4782e4f3-a8ba-459e-8668-e82330ae7b0d
# ╠═51fdab25-7c05-432d-a388-7949cfeddb3e
# ╠═6ed6bcf1-4b61-4adf-ae18-22959bac3f1f
# ╠═92d24137-9c9c-4b0c-b335-75dcf2b9b36a
# ╠═df926619-dc2c-48ce-80bd-5481bfe8b74a
# ╠═49d6deec-8929-4e17-9ba7-a23cec4de568
# ╠═32a45743-7e12-4b34-aa9f-8feebc5433a9
# ╠═d7683354-8f06-4c61-80ff-64b7a171c850
# ╟─25f01e6a-303f-45e9-b860-d53cb12c2525
# ╠═bcef50dc-78cf-4fe0-97fd-9810dc1fb5ab
# ╟─82ce8603-027a-4197-8d9e-d6c471e416ed
# ╠═ffe405e7-33f9-46c2-9436-cecb729fefc3
# ╠═f2a72f90-7841-4ccd-a09d-2c94f54476e8
