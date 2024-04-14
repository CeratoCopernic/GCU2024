### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ c7e31109-3c17-4880-b870-6dd45eb29aa1
begin
	using Pkg
	cd("/Users/alexandredemerode/Desktop/Jeu Perm - GCU 2024")
	Pkg.activate(pwd())
	#using NativeSVG
	using PlutoUI
	using Pluto
	using Printf
	#using SimpleDrawing
	#using Plots
	#using Interact
	using PrettyTables
	#using Genie
	#using Observables
	#using GLMakie
	using HypertextLiteral
end

# ╔═╡ b9b43e1a-fac4-403c-9bd7-02e9126f0ca8
md" # JEU PERMANENT GCU 2024
##### POWERED BY : 
Baden Powell Belgian Lonescouts - Commission jeu permanent GCU 2024

##### READ ME :
Le Jeu permanent du GCU 2024 est un jeu de stratégie qui se déroule sur une carte fictive maatérialisée par une grande table en bois. Les règles du jeu seront complètement décrites dans un docuement pdf annexe à ce code. 

Le jeu est relativement complexe et il est physiquement compliqué de représenter toutes les données en temps réel sur le plateau. Il a donc été décidé de stocker l'ensemble des informations du jeu dans un software, afin de : 
- Simplifier l'exécution des différents tours en automatisant la plupart des actions ;
- Permettre aux joueurs d'accéder plus rapidement et de manière plus claire aux informations du jeu.
Ce software est codé en `Julia` (extension .jl) et l'interface utilisé est un notebook `Pluto` (il s'agit du document que vous êtes en train de lire). Un tutoriel pour installer tout le nécessaire pour faire tourner le code sera présenté dans un document .pdf anexe.

Ce notebook `Pluto` est structuré de sorte à faciliter la compréhension des administrateurs du jeu (chefs et Staff des Troupes). Il est divisé en 2 grandes parties :
- **La partie A** : Dans cette partie, toutes les structures et fonctions du jeu sont présentées. Chaque fonction est accompagnée d'un paragraphe - encadré dans un box grisâtre - qui décrit son fonctionnement. Pour accéder au code des fonctions, l'utilisateur doit cliquer sur l'icône d'oeil qui se présente en haut à gauche de la box grisâtre qui décrit la fonction. 
- **La partie B** : Dans cette partie, l'interface du jeu est disposée.
**REMARQUE** : Il est vivement déconseillé de modifier quoi que ce soit dans la partie A, sous risque de modifier le fonctionnement du jeu. Lors du déroulement du jeu, seule la partie B doit être modifiée. "

# ╔═╡ 27d48cc9-69bb-49f1-8290-ac821e6f77d9
md" ## PARTIE A - FONCTIONS DU JEU"

# ╔═╡ 9462050f-92ca-4c33-b1f8-afcc80ede3cf
md" ### 1. Squelette du jeu : les structures"

# ╔═╡ 0e22a490-62b1-485b-80b6-6b046062ece8
md" Les structures Sont le squelette du jeu : elles doivent être vues comme des entités, qui ont chacune des caractéristiques bien déterminées. Dans le cas du jeu permanent, nous avons besoin de deux structures.
##### Structure `territoire`
chaque territoire possède une série de caractéristique, à savoir :
- Un numéro d'identité, qui correspond au numéro affiché sur la tableau de jeu physique ;
- un certain nombre de troupe, qui peut varier au cours du jeu en fonction des décisisons stratégiques des joueurs et des invasions/découvertes de nouveaux territoires ;
- Un nombre de bateau (uniquement pour els territoires fluviaux ou côtiers), qui peut varier lui aussi ;
- les richesses (minerais, blé, bois, pierre) que le territoire rapporte à son hôte à chaque tour. Ces richesses rapportées sont fixes et peuvent être doublées en si certains bâtiments sont construits sur les territoires ;
- Des bâtiments (femre, caserne, port) qui, une fois comstruits sur un territoire, permettent de doubler le revenu du territoire dans une certaine richesse. NB : un seu territoire de chaque type peut être construit par territoire
- Des caractéristiques géographiques : qui disent simplement si oui ou non le territoire est côtier, en bordure de fleuve, ou au pied d'une chaîne de montagnes."

# ╔═╡ f29c16f1-b8a2-41d4-986b-4b83dec9032d
mutable struct Territoire
	CaseID::Int
	Type::Int
	Troupe::String
	Soldats::Float64
	Bateaux::Float64
	Minerais::Float64
	Blé::Float64
	Bois::Float64
	Pierre::Float64
	Ferme::Bool
	Scierie::Bool
	Carrière::Bool
	Mine::Bool
	Port::Bool
	IsFluvial::Bool
	IsCoast::Bool
	IsMountains::Bool
	#Neighbours::Array
end

# ╔═╡ ba82811c-91b4-4355-97ce-ea731c2000c9
md"##### Structure `troupe`
La seconde structure est la structure troupe, elle rassemble l'ensemble des informations sur chacun des joueurs, à savoir :
- Le nom de la troupe ;
- Le nombre de territoires que la troupe possède à un instant $t$ ;
- le nombre de Soldats que la troupe possède à un instant $t$ ;
- La quantité de chaque richesse que la troupe possède à un instant $t$
Notez que la quantité de sel que possède une troupe n'est pas directement stockée dans le jeu : elle l'est physiquement à l'extérieur du jeu." 

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
md"### 2. Définition des constantes du jeu 
Dans cette section, les paramètres constants du jeu sont définis. Ceux-ci ne changeront pas au cours du jeu. On y retrouve :
- Trois vecteurs qui contiennent chacun l'ensemble des ID des territoires qui sont côtiers, en bordure de fleuve ou au pied des montagnes ;
- Quatre vecteurs qui contiennent le coût en ressource de la construction des différents bâtiments (chaque vecteur contient 4 éléments, qui dans l'ordre explicitent les coûts en bois, en pierre, en blé et en minerais) ;
- Un nombre `Sal_Sold`, qui représente ce que coûte un soldat par tour (en blé)
- Une liste de noms `Troupe_Names`, qui contient les noms des 10 troupes et des autochtones
- Un nombre `World_Size` qui correspond aux nombre de territoires dans le monde"

# ╔═╡ 2bebe9c0-b5af-4336-825a-9add6581d21d
# ENTRER ICI LES CARACTERISTIQUES FIXES DU JEU
begin
	const Coast = [1,2,3,4,5,6,11,10,16,22,23,28,27,31,30,26,25,24,29,19,18,17,12,32,33,34,35,36,37,40,43,51,52,54,60,67,68,71,72,74,73,70,64,65,66,58,59,49,50,48,42,39,75,76,77,78,79,80,81,82,83,84,87,106,107,103,102,104,105,100,97,93,92,88,89,90,99,96,94,91,85,86,108,109,110,111,113,114,115,124,127,133,134,135,144,153,154,151,150,149,157,156,155,146,145,136,137,128,116,158,159,160,161,162,163,164,165,166,171,180,187,190,189,188,185,184,183,182,175,176,172,168,167,191,192,193,194,195,196,201,205,214,223,222,230,233,232,228,227,231,226,225,224,215,207,206,202,234,235,236,237,238,239,240,241,242,243,244,245,246] #Liste des territoires côtiers
	const Fluv = [1,2,9] #Liste des territoires en bordure de fleuve
	const Mount = [5,8,9] #Liste des territoires montagneux
	const Farm_Cost = [90 100 0 0] #Ordre : Bois, Pierre, Blé, Minerais
	const Mine_Cost = [90 100 0 0]
	const Saw_Cost = [90 100 0 0]
	const Carr_Cost = [90 100 0 0]
	const Boat_Cost = [200 0 0 15]
	const Sold_Cost = [0 0 0 10]
	const SoldEntr_Cost = [0 0 10 0]
	const Port_Cost = [150 300 0 0]
	const Start_Ressources = [1100 1100 1500 100]
	const Troupe_Names = ["Archers", "Hardis", "Paladins","Lanciers","Gueux","Preux","Vaillants","Chevaliers","Templiers","Servants","Autochtones"]
	const World_Size = 246
	const Ref_Money = 500
	const Bois_Val = [10, 10, 10, 10, 10, 10, 20, 20, 10, 10, 10, 20, 20, 10, 10, 10, 20, 20, 20, 10, 10, 10, 10, 20, 10, 10, 10, 10, 20, 10, 10, 0, 0, 0, 10, 10, 10, 20, 20, 10, 10, 20, 10, 10, 20, 20, 20, 20, 20, 20, 10, 10, 10, 10, 10, 10, 20, 20, 20, 10, 10, 10, 10, 20, 20, 20, 10, 10, 10, 10, 10, 10, 10, 10, 0, 0, 0, 10, 10, 10, 10, 20, 20, 20, 20, 20, 20, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 70, 70, 70, 70, 70, 70, 60, 60, 70, 70, 70, 70, 70, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 0, 0, 0, 20, 20, 20, 10, 10, 10, 20, 20, 20, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 70, 70, 70, 70, 70, 70, 70, 70, 70, 10, 10, 60, 70, 10, 10, 60, 60, 60, 60, 60, 60, 60, 10, 10, 60, 60, 10, 10, 60, 10, 10, 10, 10, 60, 60, 60, 10, 10, 10, 10, 10, 10, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	const Min_Val = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 20, 20, 10, 10, 10, 10, 20, 20, 10, 10, 10, 20, 20, 10, 10, 10, 20, 10, 0, 0, 0, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 70, 60, 60, 70, 60, 60, 60, 70, 70, 70, 70, 60, 60, 60, 70, 70, 70, 70, 70, 70, 70, 70, 0, 0, 0, 20, 20, 20, 20, 10, 10, 10, 10, 10, 10, 20, 20, 20, 20, 20, 20, 10, 10, 10, 20, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 20, 20, 10, 10, 20, 10, 10, 20, 20, 20, 10, 10, 10, 10, 10, 20, 20, 20, 20, 20, 10, 10, 10, 10, 20, 20, 20, 20, 10, 10, 10, 10, 10, 10, 20, 20, 10, 0, 0, 0, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 20, 20, 10, 10, 10, 10, 10, 20, 20, 20, 20, 20, 10, 10, 10, 10, 10, 10, 10, 10, 10, 70, 70, 10, 10, 70, 70, 10, 10, 10, 10, 10, 10, 10, 70, 70, 10, 10, 60, 60, 10, 60, 60, 60, 70, 10, 10, 10, 60, 60, 60, 60, 60, 60, 60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	const Pir_Val = [70, 70, 70, 70, 70, 70, 60, 60, 70, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 0, 0, 0, 20, 20, 20, 10, 10, 20, 20, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 0, 0, 0, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 20, 20, 20, 10, 20, 10, 20, 20, 10, 10, 20, 20, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 20, 10, 10, 10, 10, 10, 20, 20, 20, 20, 10, 10, 10, 10, 20, 20, 20, 20, 20, 20, 10, 10, 20, 0, 0, 0, 60, 60, 60, 70, 70, 70, 60, 60, 60, 70, 70, 60, 60, 70, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 20, 20, 10, 20, 20, 20, 10, 10, 10, 10, 20, 20, 20, 20, 20, 20, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	const Blé_Val = [10, 10, 10, 10, 10, 10, 10, 10, 10, 20, 20, 10, 10, 10, 10, 20, 10, 10, 10, 10, 10, 20, 20, 10, 10, 10, 20, 20, 10, 10, 20, 0, 0, 0, 10, 10, 10, 10, 10, 10, 10, 10, 20, 20, 10, 10, 10, 10, 10, 10, 20, 20, 10, 20, 20, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 0, 0, 0, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 70, 60, 60, 70, 70, 60, 60, 70, 70, 10, 10, 10, 10, 10, 10, 20, 20, 10, 10, 10, 10, 10, 10, 10, 20, 20, 10, 20, 20, 10, 10, 10, 20, 20, 20, 20, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 0, 0, 0, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 20, 20, 10, 20, 20, 20, 20, 10, 10, 20, 20, 20, 20, 20, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 20, 10, 10, 10, 20, 20, 20, 20, 20, 20, 20, 10, 10, 20, 20, 10, 10, 20, 10, 10, 10, 10, 20, 20, 20, 10, 10, 10, 10, 10, 10, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	const Types_Val = [2, 2, 3, 3, 2, 4, 3, 3, 3, 1, 3, 2, 2, 2, 1, 3, 2, 3, 2, 1, 4, 4, 1, 3, 2, 2, 3, 2, 3, 2, 3, 2, 1, 2, 2, 1, 3, 2, 2, 1, 1, 3, 2, 3, 2, 2, 2, 2, 3, 1, 2, 2, 2, 2, 3, 2, 3, 2, 2, 1, 3, 1, 3, 1, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 3, 3, 2, 2, 2, 2, 2, 3, 3, 2, 2, 2, 3, 3, 2, 2, 2, 2, 2, 3, 3, 2, 2, 2, 2, 2, 3, 2, 1, 4, 4, 3, 3, 3, 2, 3, 3, 3, 2, 2, 3, 3, 3, 2, 4, 3, 2, 3, 2, 2, 3, 3, 3, 3, 2, 2, 3, 2, 2, 2, 3, 4, 3, 3, 3, 3, 3, 4, 4, 3, 2, 3, 3, 3, 3, 3, 4, 4, 3, 3, 2, 2, 1, 2, 2, 1, 3, 3, 3, 2, 3, 3, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 3, 1, 3, 3, 3, 3, 2, 2, 3, 4, 3, 2, 2, 3, 3, 3, 3, 2, 3, 3, 2, 3, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 4, 2, 4, 3, 3, 2, 2, 3, 3, 4, 3, 4, 3, 4, 3, 4, 3, 3, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 ,0]
	const C1 = collect(1:31)
	const I1 = collect(32:34)
	const C2 = collect(35:74)
	const I2 = collect(75:77)
	const C3 = collect(78:105)
	const I3 = collect(106:107)
	const C4 = collect(108:157)
	const I4 = collect(158:160)
	const C5 = collect(161:190)
	const C6 = collect(191:233)
	const I5 = collect(234:236)
	const C0 = collect(237:246)
	println("Constantes définies avec succès")
end

# ╔═╡ 1d6eba18-9d51-4c96-975d-bdc9c5d2e861
md"### 3. Définition des fonctions de génération du monde
Dans la section suivante, on définit les fonctions qui servent à construire le monde au début du jeu."

# ╔═╡ 60a165a8-4e65-4948-8fd7-d8c744051037
md"##### 3.1. Création du monde et des joueurs"

# ╔═╡ 933a08ef-df41-4f9d-b755-2f467dbad556
"""
		Actors_Generators()
	Cette fonction ne prend pas d'argument et retourne un vecteur (= une liste) qui contient tous les joeurs du jeu, à savoir (les 10 troupes et les autochtones). N.B. Cette fonction se base sur la constante `Troupe_Names` définie plus tôt.
	"""
function Actors_Generators()
	Actors = []::Any
	for element in Troupe_Names
		push!(Actors,Troupe(element,0,0,0,0,0,0,0))
	end
	return Actors
end

# ╔═╡ 03951448-2744-4668-a5c0-13a3cb57c8db
md"##### 3.2. Assignation des caractéristiques géographiques aux territoires"

# ╔═╡ 2fa4706b-f1ca-4fa0-8568-b0512936d8b2
"""
		Fluv_Terr(World_Mat,Terr_Mat)
		
	Cette fonction prend en arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Un vecteur qui contient tous les territoires qui se situent en bordure d'un fleuve
	Donc une fois que cette fonctions a tourné, le prgramme sait quels territoires se trouvent en bordure de fleuve (leur field `IsFluvial` vaudra `true`).
	"""
function Fluv_Terr(World_Mat,Terr_Mat)
	for Terr in World_Mat
		if Terr.CaseID in Terr_Mat
			Terr.IsFluvial = true
		end
	end
end

# ╔═╡ 000d6c33-dc9f-4ddb-8439-20d1a7a98d82
"""
		Coast_Terr(World_Mat,Terr_Mat)
		
	Cette fonction prend en arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Un vecteur qui contient tous les territoires côtiers
	Donc une fois que cette fonctions a tourné, le programme sait quels territoires sont côtiers (leur field `IsCoast` vaudra `true`).
	"""
function Coast_Terr(World_Mat,Terr_Mat)
	for Terr in World_Mat
		if Terr.CaseID in Terr_Mat
			Terr.IsCoast = true
		end
	end
end

# ╔═╡ 5ebd7c4e-6dba-44dc-b4fe-8fcaf4f5b09c
"""
		Mount_Terr(World_Mat,Terr_Mat)
		
	Cette fonction prend en arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Un vecteur qui contient tous les territoires qui se situent au pied d'une chaîne de montagnes
	Donc une fois que cette fonctions a tourné, le programme saura quels territoires se trouvent au pied d'une chaîne de montagnes (leur field `IsMountains` vaudra `true`).
	"""
function Mount_Terr(World_Mat,Terr_Mat)
	for Terr in World_Mat
		if Terr.CaseID in Terr_Mat
			Terr.IsMountains = true
		end
	end
end

# ╔═╡ 0b8cd34c-02e7-4559-a687-bc1a8f020ddf
"""
		World_Generator(Nbr_Terr)
	Cette fonction prend comme argument le nombre de territoires qui composent le monde et construit un vecteur (une liste) qui contient toutes les territoires (= cases) du monde. Par défaut, tous les territoires appartiennent aux autochtones
	"""
function World_Generator(Nbr_Terr)
	World_Matrix = []::Any
	for i in 1:Nbr_Terr
		push!(World_Matrix,Territoire(i,0,"Autochtones",0,0,0,0,0,0,false,false,false,false,false,false,false,false))
	end
	Coast_Terr(World_Matrix,Coast)
	Fluv_Terr(World_Matrix,Fluv)
	Mount_Terr(World_Matrix,Mount)
	return World_Matrix
end

# ╔═╡ 4e2210be-c52e-42b7-9bd8-3ed46e62a4e3
function Start_Game()
	World_Matrix =  World_Generator(World_Size)
	Actors_Matrix = Actors_Generators()
	#Assignation des caractéristiques géographiques (cf. const)
	Fluv_Terr(World_Matrix,Fluv)
	Coast_Terr(World_Matrix,Coast)
	Mount_Terr(World_Matrix,Mount)
	#Assignations des rentes aux territoires (cf. const)
	for i in 1:World_Size
		World_Matrix[i].Minerais = Min_Val[i]
		World_Matrix[i].Blé = Blé_Val[i]
		World_Matrix[i].Bois = Bois_Val[i]
		World_Matrix[i].Pierre = Pir_Val[i]
	end
	#Assignation d'un certain nombre de ressources à chaque troupe
	for element in Actors_Matrix
		element.Bois = Start_Ressources[1]
		element.Pierre = Start_Ressources[2]
		element.Blé = Start_Ressources[3]
		element.Minerais = Start_Ressources[4]
	end
	#Assignation du territoire de base de chaque troupe. chaque troupe démarre avec 30 soldats et 1 bateau
	for i in collect(1:10)
		Base_Terr = World_Matrix[247-i]
		Base_Terr.Troupe = Actors_Matrix[i].Nom
		Base_Terr.Soldats = 30
		Base_Terr.Bateaux = 1
	end
	#Il y a entre 1 et 5 soldats autochtones par territoire au début du jeu
	for element in World_Matrix[1:236]
		element.Soldats = round(4*rand(1)[1])+1
	end
	return World_Matrix, Actors_Matrix
end

# ╔═╡ 28d3f46d-3258-4c9b-bffa-13d9f464cbd5
md"##### 3.3. Création d'une situation de jeu fictive"

# ╔═╡ abd800af-4f8f-48bb-9588-f43c75957605
"""
		Temporary_WorldFiller(World_Matrix,Actors_Matrix)

	Cette fonction prend en argument le vecteur contenant tous els territoires du monde et permet de et rempli chaque territoire avec certaines caractéristiques aléatoires pour simuler une situation de jeu en pleine partie. 

	**N.B.** Cette fonction est provisoire : elle sert uniquement à tester les fonctions suivantes pour vérifier que le jeu tourne correctement. Elle ne sera pas utilisée à terme pour le déroulement du jeu en réel : elle deviendra plus tard la foncion `Start_Game()` et devra, à cette fin, être modifiée pour ne plus créer une situation fictive
	"""
function Temporary_WorldFiller(World_Matrix,Actors_Matrix)
	for Terr in World_Matrix
		Terr.Minerais=30*rand(1)[1]
		Terr.Blé=30*rand(1)[1]
		Terr.Bois=30*rand(1)[1]
		Terr.Pierre=30*rand(1)[1]
		Terr.Soldats = round(10*rand(1)[1])
	end
	for element in Actors_Matrix
		element.Bois = Start_Ressources[1]
		element.Pierre = Start_Ressources[2]
		element.Blé = Start_Ressources[3]
		element.Minerais = Start_Ressources[4]
	end
	for i in 1:Int(round(size(World_Matrix)[1]/5))
		World_Matrix[i].Troupe = rand(Troupe_Names)
	end
	return World_Matrix
end

# ╔═╡ dc8eff81-5e94-4cb2-8e78-b822f307a120
md"##### 3.4. Assignation de leurs caractéristiques aux troupes
Les fonctions crées plus haut permettent de remplir chaque territoire avec un certain nombre d'informations. Mais pour le moment, ces informations ne sont pas encore reliées aux différents joueurs. 

Il est donc nécessaire d'effectuer le lien entre les deux pour que le jeu sache qui possède quoi. Ceci est possible grâce aux fonctions disposées dans cette section."

# ╔═╡ 4782e4f3-a8ba-459e-8668-e82330ae7b0d
"""
		Assign_MilQties(World_Matrix,Actors_Matrix,Troupe::String)

	Cette fonction prend 3 arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le vecteur qui contient tous les joueurs ;
	- Le nom de la troupe que l'on souhaite traiter.
	
	Elle assigne à la troupe qui est appelée le nombre de soldats et de bateaux dont elle dispose.
	"""
function Assign_MilQties(World_Matrix,Actors_Matrix,Troupe::String)
	#Data collection
	Trr_Count = 0
	Sld_Count = 0
	Bot_Count = 0
	Civ_Count = 0
	Min_Count = 0
	Blé_Count = 0
	Wod_Count = 0
	Stn_Count = 0
	for Terr in World_Matrix
		if Terr.Troupe == Troupe
			Trr_Count += 1
			Sld_Count += Terr.Soldats
			Bot_Count += Terr.Bateaux
		end
	end
	#Filling the Actors matrix
	for element in Actors_Matrix
		if element.Nom == Troupe
			element.Territoires = Trr_Count
			element.Soldats = Sld_Count
			element.Bateaux = Bot_Count
			return element
		end
	end
end	

# ╔═╡ 25f01e6a-303f-45e9-b860-d53cb12c2525
"""
		Update_LonesSituation(World_Matrix,Actors_Matrix,Option)
	Cette fonction prend 3 arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le vecteur qui contient tous les joueurs ;
	- Un champ `Option` qui peut prendre 2 valeurs : `"Print"` ou `"NoPrint"`

	Cette fonction exécute la fonction `Assign_MilQties(World_Matrix,Actors_Matrix,Troupe)` pour l'ensemble des troupes et : 
	- N'affiche rien si `Option = "NoPrint"` ;
	- Affiche un tableau récapitulatif de la situation des troupes si `Option = "Print"`.
	"""
function Update_LonesSituation(World_Matrix,Actors_Matrix,option)
	# Update all troupes stats
	for troupe in Troupe_Names
		Assign_MilQties(World_Matrix,Actors_Matrix,troupe)
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

	#Display the data in a pretty table if option == "print"
	if option == "Print"
		with_terminal() do
			pretty_table(data,body_hlines = collect(1:11);header = header)
		end
	elseif option == "NoPrint"
		return LonesSit
	end
end

# ╔═╡ b04c0ee0-ec1d-4af1-ab36-2f3e1fdf918b
md"### 4. Fonctions de collecte de données
Les fonctions présentées dans cette section permettent de collecter des données sous différentes formes. Elles s'appellent les unes les autres et seront utilisées dans les fonctions plus générales qui serviront à implémenter le déroulement de la partie."

# ╔═╡ 51fdab25-7c05-432d-a388-7949cfeddb3e
"""
		Properties(World_Matrix,Troupe::String)
	Cette fonction prend 2 arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le nom de la troupe dont on souhaite extraires les informations
	
	Elle retourne un vecteur donc chaque élément correspond au numéro d'identité d'un territoire qu'elle possède. Elle permet donc d'identifier rapidement tous les territoires qu'une troupe possède.
	
	**N.B.** Normalement, ces informations devront aussi être affichées physiquement sur le plâteau, en mettant les drapeux des troupe ssur les territoires qu'elles possèdent. Cette fonction permet néanmoins une visualisation plus rapide. 
	"""
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
"""
		Find_Troup(Troupe::String, Actors_Matrix)
	Cette fonction sert à extraire la structure `troupe` qui correspond au nom d'une troupe. Elle prend 2 arguments : 
	- Le nom de la troupe que l'on souhaite extraire du vecteur des joueurs ;
	- Le vecteur qui contient tous les joueurs.
	Elle retourne la structure troupe dont le nom a été appelé en argument.
	"""
function Find_Troup(Troupe::String, Actors_Matrix)
	Trp = []::Any
	for element in Actors_Matrix
		if element.Nom == Troupe
			push!(Trp, element)
		end
	end
	return Trp[1]
end

# ╔═╡ 57d50a15-7578-4348-bc38-5e4196bf26c6
"""
		Find_Terr(Terr::Int,World_Matrix)
	Cette fonction sert à extraire la structure `Territoire` qui correspond à un numéro d'identité de territoire. Elle prend 2 arguments : 
	- Le numéro d'identité du territoire que l'on souhaite extraire du vecteur du monde ;
	- Le vecteur qui contient tous les joueurs.
	Elle retourne la structure territoire dont le numéro a été appelé en argument.
	"""
function Find_Terr(Terr::Int,World_Matrix)
	Tr = []::Any
	for element in World_Matrix
		if element.CaseID == Terr
			push!(Tr,element)
		end
	end
	return Tr[1]
end

# ╔═╡ 2194282d-5203-4d1d-965e-b40469064624
md"### 5. Fonctions de modification du jeu
Nous avons à présent toutes les fonctions qui permettent de créer le monde et ses joueurs et de collecter un certains nombre de données. Sur base de ces dernières, nous allons maintenant définir les fonctions qui permettent de modifier l'état du jeu en fonction des actions des joueurs."

# ╔═╡ f2a72f90-7841-4ccd-a09d-2c94f54476e8
"""
		Add_Entity(World_Matrix,Actors_Matrix,Terr::Territoire, Entity::String)
	Cette fonction sert à ajouter un bâtiment sur un territoire donné. Elle prend 4 arguments :
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le vecteur qui contient tous les joueurs ;
	- Le territoire sur lequel on souhaite ajouter un bâtiment ;
	- Le type de bâtiment que le joueur souhaite ajouter.
	Elle retourne le territoire (juste pour montrer, au besoin, que la fonction a été exécutée avec succès), mais ce qu'elle fait surtout c'est : 
	- Ajouter le bâtiment demandé sur le territoire appelé en argument ;
	- Débiter le portefeuille de la troupe qui achhète du prix que coûte le bâtiment qu'elle ajoute. 
	"""
function Add_Entity(World_Matrix,Actors_Matrix,Terr::Territoire, Entity::String)
	Actor = Terr.Troupe
	ID = Terr.CaseID
	Data = Assign_MilQties(World_Matrix,Actors_Matrix,Actor::String)
	Cost = [0 0 0 0]
	if Entity == "Ferme"
		if Terr.Ferme == false
			Cost = Farm_Cost
			Terr.Ferme = true
			pr = "Achat effectué : Les $Actor ont construit une ferme sur le territoire n°$ID."
		elseif Terr.Ferme == true
			pr = "Achat non effectué : Le territoire contient déjà une ferme."
			pr = "Achat effectué : Les $Actor ont construit une ferme sur le territoire n°$ID."
		end
	elseif Entity == "Scierie"
		if Terr.Scierie == false
			Cost = Saw_Cost
			Terr.Scierie = true
			pr = "Achat effectué : Les $Actor ont construit une scierie sur le territoire n°$ID."
		elseif Terr.Scierie == true
			pr = "Achat non effectué : Le territoire contient déjà une sciereie."
		end
	elseif Entity == "Carrière"
		if Terr.Carrière == false
			Cost = Carr_Cost
			Terr.Carrière = true
			pr = "Achat effectué : Les $Actor ont construit une carrière sur le territoire n°$ID."
		elseif Terr.Carrière == true
			pr = "Achat non effectué : Le territoire contient déjà une carrière."
		end
	elseif Entity == "Mine"
		if Terr.Mine == false
			Cost = Mine_Cost
			Terr.Mine = true
			pr = "Achat effectué : Les $Actor ont construit une mine sur le territoire n°$ID."
		elseif Terr.Mine == true
			pr = "Achat non effectué : Le territoire contient déjà une mine."
		end
	elseif Entity == "Port"
		if Terr.Port == false
			Cost = Port_Cost
			Terr.Port = true
			pr = "Achat effectué : Les $Actor ont construit un port sur le territoire n°$ID."
		elseif Terr.Port == true
			pr = "Achat non effectué : Le territoire contient déjà un port."
		end
	elseif Entity == "Bateau"
		Cost = Boat_Cost
		Terr.Bateaux = Terr.Bateaux+1
		pr = "Achat effectué : Les $Actor ont ajouté un bâteau sur le territoire n°$ID."
	elseif Entity == "Soldat"
		Cost = Sold_Cost
		Terr.Soldats = Terr.Soldats+1
		pr = "Achat effectué : Les $Actor ont ajouté un soldat sur le territoire n°$ID."
	end
	#Ordre de la matrice Cost : Bois, Pierre, Blé, Minerais
	Data.Bois = Data.Bois-Cost[1]
	Data.Pierre = Data.Pierre-Cost[2]
	Data.Blé = Data.Blé-Cost[3]
	Data.Minerais = Data.Minerais-Cost[4]
	return pr
end
# Note : ne fait pour le moment rien si une entité bool existe déjà (with_terminal ne rend rien je dois réfléchir à ça)
# Note : Pour le moment, aucune vérification n'est faite sur si oui ou non la troupe a assez d'argent pour acheter le territoire (à changer).

# ╔═╡ 3ffe698b-10f7-4164-93f5-d9338775cc74
"""
		Transfer_Troups(World_Matrix,TerrInit,TerrDest,Nbr)
Cette sert à transférer des souldats d'un territoire à un autre. Elle prend 4 arguments : 
- Le vecteur qui contient tous les territoires composant le monde ;
- La structure `Territoire` du territoire de départ (où les troupes se situent initialement) ;
- La structure `Territoire` du territoire de destination (où les troupes désirent être déplacées) ;
- Le nombre de troupes su'il faudrait déplacer.
Elle retourne un message qui traduit le statut d'exécution de la fonction. NB : Pour le moment, le programme ne vérifie pas que les territoires sont voisins. 
	"""
function Transfer_Troups(World_Matrix,TerrInit::Territoire,TerrDest::Territoire,Nbr)
	if TerrInit.Troupe == TerrDest.Troupe
		Trp = TerrInit.Troupe
		Terr_it = TerrInit.CaseID
		Terr_dt = TerrDest.CaseID
		if TerrInit.Soldats > Nbr
			TerrInit.Soldats = TerrInit.Soldats-Nbr
			TerrDest.Soldats = TerrDest.Soldats+Nbr
			pr = "Transfert effectué : $Nbr Soldats ont été transférés du territoire n°$Terr_it vers le territoire n°$Terr_dt par les $Trp"
		elseif TerrInit.Soldats == Nbr
			pr = "Transfert impossible : vous devez au moins garder un soldat sur le territoire pour pouvoir l'occuper"
		else
			pr = "Transfert impossible : vous n'avez pas assez de soldats sur le territoire initial"
		end
	else
		pr = "Transfert impossible : Vous devez choisir des territoires qui vous appartiennent"
	end
	return pr
end
#Note : ne vérifie pas si les territoires sont adjacents...

# ╔═╡ 6c0a40cd-d316-42bb-955a-00f2afdbefa0
"""
		Ressource2Salt(Actors_Matrix,Troupe::String,Ressource::String,Quantity)
Cette fonction permet de convertir instantanément n'importe quelle quantité de ressource en sel. Elle prend 4 arguments : 
- Le vecteur qui contient tous les joueurs ;
- Le nom de la troupe qui souhaite convertir une ressource en sel ;
- Le nom de la ressource que la troupe souhaite échanger ;
- La quantité de cette ressource qui souhaite être échangée.
Puisque le sel n'est pas stocké dans le programme mais en réel, cette fonction n'ajoute pas de sel à une troupe dans le programme : 
- Elle vérifie que la troupe a effectivement assez de ressources pour effectuer cet échange ;
- Elle retire le nombre de ressources échangées à la fortune de la troupe ; 
- Elle afgfiche un message qui indique la quantité de gramme de sels qui doivent être versés dans le pot de la troupe (en réel).

Si ce dernier message s'affiche, ça veut dire que les ressources ont déjà été retirées une fois. Attention, en faisant tourner la fonction deux fois, on retire deux fois les ressources !
	"""
function Ressource2Salt(Actors_Matrix,Troupe::String,Ressource::String,Quantity)
	# Quantity doit être exprimée en grammes
	Trp = Find_Troup(Troupe,Actors_Matrix)
	if Ressource == "Blé"
		Cost = Quantity
		Salt_obtnd = Quantity/100
		if Trp.Blé >= Cost
			Trp.Blé = Trp.Blé-Cost
			pr = "Les $Troupe viennent d'échanger $Quantity unités de blé contre $Salt_obtnd grammes de sel"
		else
			pr = "Les $Troupe n'ont pas assez de $Ressource pour effectuer cet échange"
		end
	elseif Ressource == "Pierre"
		Cost = Quantity
		Salt_obtnd = Quantity/100
		if Trp.Pierre >= Cost
			Trp.Pierre = Trp.Pierre-Cost
			pr = "Les $Troupe viennent d'échanger $Quantity unités de pierre contre $Salt_obtnd grammes de sel"
		else
			pr = "Les $Troupe n'ont pas assez de $Ressource pour effectuer cet échange"
		end
	elseif Ressource == "Minerais"
		Cost = Quantity
		Salt_obtnd = Quantity/100
		if Trp.Minerais >= Cost
			Trp.Minerais = Trp.Minerais-Cost
			pr = "Les $Troupe viennent d'échanger $Quantity unités de minerais contre $Salt_obtnd grammes de sel"
		else
			pr = "Les $Troupe n'ont pas assez de $Ressource pour effectuer cet échange"
		end
	elseif Ressource == "Bois"
		Cost = Quantity
		Salt_obtnd = Quantity/100
		if Trp.Bois >= Cost
			Trp.Bois = Trp.Bois-Cost
			pr = "Les $Troupe viennent d'échanger $Quantity unités de bois contre $Salt_obtnd grammes de sel"
		else
			pr = "Les $Troupe n'ont pas assez de $Ressource pour effectuer cet échange"
		end
	end
	return pr
end

# ╔═╡ 49d6deec-8929-4e17-9ba7-a23cec4de568
"""
		Actualise_Fortuna(World_Matrix,Actors_Matrix,Troupe::Troupe,Action)
Cette fonction prend 4 arguments : 
- Le vecteur qui contient tous les territoires composant le monde ;
- Le vecteur qui contient tous les joueurs ;
- Le nom de la troupe que l'on souhaite traiter ;
- L'action que l'on souhaite exécuter. 
Elle ne retourne rien, me permet simplement d'exercer une action pour la troupe mentionnée. Les différentes actions possibles sont : 
- `"New_turn"` : qui permet de verser les rentes aux troupes en fonction des territoires qu'elle possède

**N.B.** Pour le moment, la seule action possible est celle décrite ci-dessus. **Je ne pense pas que cette fonction sera utilisée dans le jeu au final** (elle va être remplacée par la fonction `New_Turn`, décrite ci-dessous)

	"""
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

# ╔═╡ 554d8c87-8a34-4ca2-98ff-443dc8226381
"""
		New_Turn(World_Matrix,Actors_Matrix)
Cette fonction exécute un nouveau tour. Elle prend 2 arguments : 
- Le vecteur qui contient tous les territoires composant le monde ;
- Le vecteur qui contient tous les joueurs ;
Elle ne retourne rien mais exécute les actions suivantes : 
- Verse à chaque troupe les rentes de leurs territoires respectifs ;
- Retire à chaque troupe la quantité de blé nécessaire pour entretenir son armée. Si la quantité de blé est insuffisante, la quantité de blé est mise à 0 et la troupe perd 1/3 de ses effectifs sur tous ses territoires (encore à implémenter : ne marche pas pour le moment)
	"""
function New_Turn(World_Matrix,Actors_Matrix)
	for Trp in Actors_Matrix
		Prop = Properties(World_Matrix,Trp.Nom)
		for i = 1:size(Prop)[1]
			CaseID = Prop[i]
			Terr = World_Matrix[CaseID]
			if Terr.Ferme == true
				Trp.Blé += 2*Terr.Blé
			else
				Trp.Blé += Terr.Blé
			end
			if Terr.Scierie == true
				Trp.Bois += 2*Terr.Bois
			else
				Trp.Bois += Terr.Bois
			end
			if Terr.Carrière == true
				Trp.Pierre += 2*Terr.Pierre
			else
				Trp.Pierre += Terr.Pierre
			end
			if Terr.Mine == true
				Trp.Minerais += 2*Terr.Minerais
			else
				Trp.Minerais += Terr.Minerais
			end
		end
		Sold_Nbr = Trp.Soldats
		Army_Cost = Sold_Nbr*SoldEntr_Cost[3]
		if Trp.Blé >= Army_Cost
			Trp.Blé = Trp.Blé-Army_Cost
		else
			TerrTrp = Properties(World_Matrix,Trp.Nom)
			Territories = []::Any
			for element in World_Matrix
				if element.CaseID in TerrTrp
					element.Soldats = floor(element.Soldats-(1/3)*element.Soldats)
				end
			end
			Trp.Blé = 0
		end
	end
end
#Note : Prévoir une fonciton qui fait l'inverse en cas d'erreur de manip ? 
#Note : Il ne se passe rien si la troupe passe en négatif à cause des soldats...

# ╔═╡ 3d3cc7ed-cf7a-4b4f-98e9-95359ad21cef
"""
			Assault(World_Matrix,Att_Terr_Int::Int, Def_Terr_Int::Int)
	Cette fonction sert à effectuer une attaque. Elle prend 3 arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le numéro d'identité du territoire attaquant ;
	- Le numéro d'identité du territoire attaqué ;
	Elle retourne une phrase qui résume se qui s'est passé durant l'attaque. En parallèle, elle effectue toutes les modifications nécessaires dans le jeu.
	"""
function Assault(World_Matrix,Att_Terr_Int::Int, Def_Terr_Int::Int)
	Att_Terr = Find_Terr(Att_Terr_Int,World_Matrix)
	Def_Terr = Find_Terr(Def_Terr_Int,World_Matrix)
	Att_nbr = Int(Att_Terr.Soldats)
	Def_nbr = Int(Def_Terr.Soldats)
	Att_Trp = Att_Terr.Troupe
	Def_Trp = Def_Terr.Troupe
    # Vérifier si les nombres de troupes sont valides
    if Att_nbr < 2 || Def_nbr < 1
        pr = "Erreur : L'attaquant doit attaquer avec au moins 2 soldats un territoire qui contient au moins 1 soldat."
	else
	    Att_nbr_rest = Att_nbr
	    Def_nbr_rest = Def_nbr
	    while Att_nbr_rest > 1 && Def_nbr_rest > 0
	        Att_dices = min(Att_nbr_rest - 1, 3)
	        Def_dices = min(Def_nbr_rest, 2)
	        Res_Att = sort(rand(1:6, Att_dices), rev=true)
	        Res_Def = sort(rand(1:6, Def_dices), rev=true)
	        for (attaque, defense) in zip(Res_Att, Res_Def)
	            if attaque > defense
	                Def_nbr_rest -= 1
	            else
	                Att_nbr_rest -= 1
	            end
	        end
	    end
		if Att_nbr_rest == 1 #Si la défense gagne
			Att_Terr.Soldats = 1
			Def_Terr.Soldats = Def_nbr_rest
			pr = "L'attaque a échoué : Les $Def_Trp ont réussi à défendre leur territoire! Il leur reste $Def_nbr_rest soldats sur leur territoire. Toutes les troupes des $Att_Trp sont tombées au combat... Seul 1 soldat reste sur le territoire $Att_Terr_Int."
		elseif Def_nbr_rest == 0 #Si l'attaque gagne
			Att_Terr.Soldats = 1
			Def_Terr.Troupe = Att_Trp
	    	Def_Terr.Soldats = Att_nbr_rest-1
			pr = "L'attaque est un succès : Les $Att_Trp ont vaincu la défense des $Def_Trp, qui ont perdu toutes leurs troupes au combat ! Les $Att_Trp occupent donc maintenant le territoire numéro $Def_Terr_Int avec $(Att_nbr_rest-1) soldats. 1 soldat est resté défendre le territoire $Att_Terr_Int."
		else
			println("Erreur 404")
		end
	end
	return pr
end

# ╔═╡ d45625d4-9e8f-4724-941e-e9b514a27651
md"### 6. Fonctions d'affichage
Les fonctions décrites dans cette section permettent de rendre **facilement** visibles différentes informations du jeu. Elle sert donc à simplifier la vie des joueurs.

**N.B.** La fonction `Update_LonesSituation(World_Matrix,Actors_Matrix,Option)`, décrite plus tôt permet également d'afficher des informations intéressantes sur l'ensemble des troupes (à condition que `Option = \"Print\"`). Elle n'est pas dans cette section car en plus d'afficher des informations, elle permet physiquement de mettre à jour les paramètres du jeu."

# ╔═╡ 82ce8603-027a-4197-8d9e-d6c471e416ed
"""
		Terr_Info(World_Matrix,Territoire::Int)
	Cette fonction prend 2 arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le numéro d'identité du territoire duquel on souhaite obtenir les informations.
	Elle retourne un texte (écrit dans le temrinal) qui donne un aperçu des caractéristiques du territoire dont le numéro appelé en argument. Dans le cadre du jeu, elle permettra donc aux scouts d'afficher les informations concernant **leurs** territoires, afin d'entreprendre les actions adéquates.
	"""
function Terr_Info(World_Matrix,Territoire::Int)
	Terr =  World_Matrix[Territoire]
	Propriétaire = uppercase(Terr.Troupe)
	Type = Terr.Type
	Soldats = Terr.Soldats
	Bateaux = Terr.Bateaux
	Minerais = round(Terr.Minerais)
	Blé = round(Terr.Blé)
	Bois = round(Terr.Bois)
	Pierre = round(Terr.Pierre)
	Ferme = "Non"
	Scierie = "Non"
	Carrière = "Non"
	Mine = "Non"
	Port = "Non"
	if Terr.Ferme == true
		Ferme = "Oui"
	else
		Ferme = "Non"
	end
	if Terr.Scierie == true
		Scierie = "Oui"
	else
		Scierie = "Non"
	end
	if Terr.Carrière == true
		Carrière = "Oui"
	else
		Carrière = "Non"
	end
	if Terr.Mine == true
		Mine = "Oui"
	else
		Mine = "Non"
	end
	if Terr.Port == true
		Port = "Oui"
	else
		Port = "Non"
	end	
	pr2 = "Territoire n°$Territoire -- $Propriétaire"
	pr3 = "--------------------------------"
	pr4 = "Nombre de soldats : $Soldats"
	pr5 = "Nombre de bateaux : $Bateaux"
	pr6 = "Richesse en minerais : $Minerais"
	pr7 = "Richesse en Blé : $Blé"
	pr8 = "Richesse en Bois : $Bois"
	pr9 = "Richesse en Pierre : $Pierre"
	pr10 = "Présence d'une ferme : $Ferme"
	pr11 = "Présence d'une scierie : $Scierie"
	pr12 = "Présence d'une carrière : $Carrière"
	pr13 = "Présence d'une mine : $Mine"
	pr14 = "Présence d'un port : $Port"
	pr15 = "Taille du territoire : $Type"
	pr_elem = [pr2, pr3, pr15, pr4, pr5, pr6, pr7, pr8, pr9, pr10, pr11, pr12, pr13, pr14]
	return pr_elem
end

# ╔═╡ 7944dc39-3a02-4237-9833-54b5865c0e19
W,A = Start_Game()

# ╔═╡ b0b8944f-fa64-4cef-ad60-81b9371f38bb
Terr_Info(W,12)

# ╔═╡ ac9c1cb6-78ad-4387-83c5-c83522f5bb6d
"""
		Properties_Info(World_Matrix,Actors_Matrix,Troupe::String,field::String)
	Cette fonction est le premier pas dans le processus d'affichage des caractéristiques des territoires d'une troupe. Elle prend 4 arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le vecteur qui contient tous les joueurs ;
	- Le nom de la troupe dont on souhaite traiter les informations ;
	- Le nom du champ que l'on souhaite afficher pour tous les territoires que la troupe possède.

	Elle retourne un dictionnaire qui associe à chaque territoire la valeur que prend le champ spécifié en argument.

	"""
function Properties_Info(World_Matrix,Actors_Matrix,Troupe::String,field::String)
	Prp = Properties(World_Matrix,Troupe)
	Data = []
	f_field = lowercase(field)
	for element in Prp
		Structure = Find_Terr(element,World_Matrix)
		Dico = Dict([
		    ("caseid", Structure.CaseID),
			("type",Structure.Type),
		    ("troupe", Structure.Troupe),
		    ("soldats", Structure.Soldats),
		    ("bateaux", Structure.Bateaux),
		    ("minerais", Structure.Minerais),
		    ("blé", Structure.Blé),
		    ("bois", Structure.Bois),
		    ("pierre", Structure.Pierre),
		    ("ferme", Structure.Ferme),
		    ("scierie", Structure.Scierie),
			("carrière", Structure.Carrière),
			("mine", Structure.Mine),
		    ("port", Structure.Port),
		    ("isfluvial", Structure.IsFluvial),
		    ("iscoast", Structure.IsCoast),
		    ("ismountains", Structure.IsMountains)
		])
		Info = Dico[f_field]
		push!(Data,Info)
	end
	DDIICCTT = Dict()
	for i in 1:length(Prp)
		line = Prp[i] => Data[i]
		push!(DDIICCTT,line)
	end
	return DDIICCTT
end

# ╔═╡ 2e77c3fc-94bd-4dfe-a8b9-4302db6b85fb
md"### 7. Fonctions \"`Execute()`\""

# ╔═╡ 79b63986-ce3a-451e-be10-4bb90f76f93a
md"### Notes Réunion 24 Mar 24
- Fonction pour les catastrophes naturelles : to do
- Imprimer une feuille avec leur situation complète quels territoires ils ont + tableau
- Carte espion : en réel
- Sauvegarde de la matrice à chaque tour .txt ou .xslx : to do
- Garde royale : to do"

# ╔═╡ 018f1d80-9fbc-4d36-a41e-319c86511b76
md"## PARTIE B - INTERFACE DE JEU"

# ╔═╡ ce6b11f9-8230-4076-8135-12df833d4a82
begin
	World = World_Generator(236) #Génère un monde vide
	Troupes = Actors_Generators() #Génère toutes les troupes
	Temporary_WorldFiller(World,Troupes) #Simule une simulation de partie en cours
	Update_LonesSituation(World,Troupes,"NoPrint") #Met à jour les avoirs de toutes les troupes
	nothing
end

# ╔═╡ a0406049-10c0-4b93-9f0e-ac7eebe6d979
md"""### AFFICHAGE
	Sélectionnez ici ce que vous souhaitez afficher :

	 $(@bind SitGen CheckBox()) Situation des troupes\
	 $(@bind PropTerr CheckBox()) Caractéristiques d'un territoire\
	 $(@bind PropTrp CheckBox()) Propriétés d'une troupe\
	"""

# ╔═╡ 400579f3-b212-4902-b96e-8659c33245da
if PropTerr == true
	md"""Numéro d'identité du territoire concerné : $@bind TInfo PlutoUI.confirm(html"<input type=text>")"""
elseif PropTrp == true
	sp = html"&nbsp"
	md""" **Cochez les informations que vous voulez voir apparaître** :\
	 $(@bind cad CheckBox()) CaseID $sp $sp $sp $sp $(@bind tye CheckBox()) Type $sp $sp $sp $sp $(@bind sdt CheckBox()) Soldats $sp $sp $sp $sp $(@bind bax CheckBox()) Bâteaux $sp $sp $sp $sp $(@bind mis CheckBox()) Minerais $sp $sp $sp $sp $(@bind ble CheckBox()) Blé $sp $sp $sp $sp $(@bind bos CheckBox()) Bois $sp $sp $sp $(@bind pie CheckBox()) Pierre $sp $sp $sp $sp $sp $(@bind fee CheckBox()) Ferme $sp $sp $sp $(@bind sce CheckBox()) Scierie $sp $sp $sp $sp $(@bind cae CheckBox()) Carrière $sp $sp $sp $sp $(@bind mie CheckBox()) Mine $sp $sp $sp $sp $sp $sp $sp $(@bind pot CheckBox()) Port $sp $sp $sp $(@bind fll CheckBox()) Fluvial $(@bind cor CheckBox()) Côtier $sp $sp $sp $sp $sp $(@bind mos CheckBox()) Mountains
	
	**Nom de la troupe concernée** : $@bind Ttp PlutoUI.confirm(html"<input type=text>")"""
end

# ╔═╡ 4a58cec4-778c-4594-ae25-2492acddc68b
"""
		Advanced_Properties_Info(World_Matrix,Actors_Matrix,Troupe::String)
	Cette fonction est le deuxième pas dans le processus d'affichage des caractéristiques des territoires d'une troupe. Elle prend 3 arguments :
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le vecteur qui contient tous les joueurs ;
	- Le nom de la troupe dont on souhaite traiter les informations ;

	Elle retourne un dictionnaire qui associe à chaque champ spécifié en cochant les cases (cf. interface du jeu), un dictionnaire qui reprend les valeurs de ce champ pour tous lesq territoires possédés par la troupe appelée en argument. Elle est à la base de la collecte des données nécessaire au bon fonctionnement de la fonction finale d'affichage, `Display_Properties_Info`, décrite ci-dessous.

	"""
function Advanced_Properties_Info(World_Matrix,Actors_Matrix,Troupe::String)
	Asked_Elements = Dict()
	button_labels = [cad, tye, sdt, bax, mis, ble, bos, pie, fee, sce, cae, mie, pot, fll, cor, mos]
	button_names = ["CaseID", "Type", "Soldats", "Bateaux", "Minerais", "Blé", "Bois", "Pierre", "Ferme", "Scierie", "Carrière", "Mine", "Port", "IsFluvial", "IsCoast", "IsMountains"]
	buttons_dict = Dict(zip(button_names, button_labels))
	for element in button_names
		if buttons_dict[element] == true
			Prps_Info = Properties_Info(World_Matrix,Actors_Matrix,Troupe,element)
			push!(Asked_Elements,element => Prps_Info)
		end
	end
	return Asked_Elements
end

# ╔═╡ 15ccf590-a109-4e7f-aa5a-b756d6fccbe9
"""
		Display_Properties_Info(World_Matrix,Actors_Matrix,Troupe::String)
	Cette fonction sert à afficher les propriétés de tous les territoires que possèdent une troupe (troisème et dernier pas, donc, dans ce processus). Elle prend 3 arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le vecteur qui contient tous les joueurs ;
	- Le nom de la troupe dont on souhaite traiter les informations ;

	Elle retourne une `pretty_table` qui contient toutes les informations nécessaires. Pour un exemple, cf. interface du jeu.
	"""
function Display_Properties_Info(World_Matrix,Actors_Matrix,Troupe::String)
	API = Advanced_Properties_Info(World_Matrix,Actors_Matrix,Troupe::String)
	Coln_header = []
	Row_header_info = Properties(World_Matrix,Troupe)
	Row_header = []
	for element in Row_header_info
		Row_header_elm = "Terr $element"
		push!(Row_header,Row_header_elm)
	end
	pushfirst!(Row_header,"CHAMPS")
	Data_mat = []
	for key in keys(API)
		push!(Coln_header,key)
		Attributes = API[key]
		Data_Cln = []
		for little_key in keys(Attributes)
			Data = Attributes[little_key]
			push!(Data_Cln,Data)
		end
		push!(Data_mat,Data_Cln)
	end
	Data_mat_final = transpose(reduce(hcat,Data_mat))
	Table = [Coln_header Data_mat_final]
	uptrp = uppercase(Troupe)
	with_terminal() do
		println("INFORMATIONS SUR LES TERRITOIRES DES $uptrp")
		println("Territoires possédés : $Row_header_info")
		println("Informations plus précises :")
		pretty_table(Table,body_hlines = collect(1:length(Coln_header));header = Row_header)
	end
end

# ╔═╡ ca705873-8374-4baa-a4c4-65d1ccdb5698
function Execute_TerrInfo()
	try 
		CaseID = parse(Int64,TInfo)
		info_vec = Terr_Info(World,CaseID)
		with_terminal() do
			for element in info_vec
				println(element)
			end
		end
	catch
		println("Veuillez remplir les cases puis cliquer sur envoyer pour confirmer votre transfert")
	end
end

# ╔═╡ 31f0c518-740d-4d6b-be63-ee953d6f477b
function Execute_Display_Properties_Info()
	try
		Display_Properties_Info(World,Troupes,Ttp)
	catch
		pr = "Veuillez cocher les informations à montrer, préciser le nom de la troupe en remplissant la case, puis cliquer sur envoyer pour afficher les informations"
		println(pr)
	end
end

# ╔═╡ 89a6d635-ff6d-44d3-b2f7-7f64bc12ea47
if SitGen == true
	Update_LonesSituation(World,Troupes,"Print")
elseif PropTerr == true
	Execute_TerrInfo()
elseif PropTrp == true
	Execute_Display_Properties_Info()
end

# ╔═╡ 91a757ac-e56c-4228-8cff-fbd25fa27714
md"""### ACTIONS

Sélectionnez ici l'action que le joueur souhaite exécuter : 

 $(@bind Turn CheckBox()) Début d'un tour\
 $(@bind Transfer CheckBox()) Transférer les troupes d'un territoire vers un autre\
 $(@bind Buy CheckBox()) Acheter un bâtiment et le placer sur un de ses territoire\
 $(@bind Salt CheckBox()) Acheter du sel avec des ressources\
 $(@bind Ass CheckBox()) Attaquer un territoire\
"""

# ╔═╡ 34d229fe-06af-4179-b44a-5c1208f86ff0
begin
	if Ass == true
	md"""### Préparez votre attaque méticuleusement !!
	Observez les caractéristiques des territoires que vous souhaitez impliquer dans l'attaque en remplissant les cases ci-dessus ! Ceci vosu permettra de prendre une meilleure décision !
	
	ID du territoire d'où part l'attaque : $(@bind AttStg html"<input type=text>")\
	ID du territoire attaqué : $(@bind DefStg html"<input type=text>")
	"""
	end
end

# ╔═╡ 3f554a7d-8d0c-4258-ab9e-2a88d41fdda1
function Execute_Display_TerrAttInfo()
	if Ass == true
		try
			Att_It = parse(Int64,AttStg)
			Def_It = parse(Int64,DefStg)
			Att_Info = Terr_Info(World,Att_It)
			Def_Info = Terr_Info(World,Def_It)
			with_terminal() do
				for i in 1:length(Att_Info)
					@printf("%-45s %-25s\n",Att_Info[i],Def_Info[i])
				end
			end
		catch
			pr = "Veuillez remplir les cases puis cliquer sur envoyer pour confirmer l'attaque."
			println(pr)
		end
	else
		return nothing
	end
end

# ╔═╡ e21132a8-c795-416d-90c1-d1817337af89
Execute_Display_TerrAttInfo()

# ╔═╡ 55be7c75-ee34-4a2e-b02d-b69402f82672
if Buy == true
	@bind Adding_Data PlutoUI.confirm(
		PlutoUI.combine() do Child
			@htl("""
			<h3>Achat d'un nouveau bâtiment</h3>
			
			<ul>
			$([
				@htl("<li>$(name): $(Child(name, html"<input type=text>"))")
				for name in ["Numéro d'identité du territoire concerné ", "Bâtiment que la troupe souhaite ajouter "]
			])
			</ul>
			""")
		end
	)
elseif Turn == true
	md"""Veuillez, par sécurité, écrire : "`Je confirme qu'un nouveau tour doit avoir lieu`" : $@bind Mess_Turn PlutoUI.confirm(html"<input type=text>")"""
elseif Transfer == true
	@bind Transfer_Data PlutoUI.confirm(
		PlutoUI.combine() do Child
			@htl("""
			<h3>Transfert de troupe(s)</h3>
			
			<ul>
			$([
				@htl("<li>$(name): $(Child(name, html"<input type=text>"))")
				for name in ["Numéro du territoire de départ ", "Numéro du territoire de destination ", "Nombre de troupes à transférer "]
			])
			</ul>
			""")
		end
	)
elseif Salt == true
	@bind Salt_Data PlutoUI.confirm(
		PlutoUI.combine() do Child
			@htl("""
			<h3>Conversion de ressource(s) en sel</h3>
			
			<ul>
			$([
				@htl("<li>$(name): $(Child(name, html"<input type=text>"))")
				for name in ["Troupe qui souhaite effectuer l'échange ","Type de ressource qu'on souhaite convertir en sel ", "Quantité de ressource que à échanger "]
			])
			</ul>
			""")
		end
	)
elseif Ass == true
	@bind Ass_Data PlutoUI.confirm(
		PlutoUI.combine() do Child
			@htl("""
			<h3>Sûr de votre coup ? Attaquez !</h3>
			
			<ul>
			$([
				@htl("<li>$(name): $(Child(name, html"<input type=text>"))")
				for name in ["ID du territoire d'où part l'attaque ","ID du territoire attaqué"]
			])
			</ul>
			""")
		end
	)
end

# ╔═╡ 3b763c2f-83d8-4be6-9fb5-e6ce1881db52
function Execute_Buy()
	try
		Entity_Type = Adding_Data[2]
		Terr_Int = parse(Int64,Adding_Data[1])
		Terr_Strct = Find_Terr(Terr_Int,World)
		Trp = Terr_Strct.Troupe
		pr = Add_Entity(World, Troupes,Terr_Strct,Entity_Type)
		println(pr)
	catch
		with_terminal() do
			println("Veuillez remplir les cases puis cliquer sur envoyer pour confirmer votre achat")
		end
	end
end

# ╔═╡ 1e15b72a-b0be-4045-961b-5e8de4cc9b4f
function Execute_Transfer()
	try
		Nbr = parse(Int64,Transfer_Data[3])
		Dep_Terr = parse(Int64,Transfer_Data[1])
		Dep_Terr_Strct = Find_Terr(Dep_Terr,World)
		Arr_Terr = parse(Int64,Transfer_Data[2])
		Arr_Terr_Strct = Find_Terr(Arr_Terr,World)
		Trp = Arr_Terr_Strct.Troupe
		pr = Transfer_Troups(World,Dep_Terr_Strct,Arr_Terr_Strct,Nbr)
		println(pr)
	catch
		with_terminal() do
			println("Veuillez remplir les cases puis cliquer sur envoyer pour confirmer votre transfert")
		end
	end
end

# ╔═╡ a1b4005e-6e10-45ee-b018-6ff5c0a1a4a9
function Execute_NewTurn()
	try
		if lowercase(Mess_Turn) == "je confirme qu'un nouveau tour doit avoir lieu"
			New_Turn(World,Troupes)
			pr = "Un nouveau tour a bien été effectué"
		elseif Mess_Turn ≠ ""
			pr = "Le message est mal écrit, veuillez recommencer"
		end
		println(pr)
	catch
		pr = "Veuillez écrire et envoyer le message suivant les instructions ci-dessus"
		println(pr)
	end
end

# ╔═╡ 8bb403e2-83e7-49b7-8c3c-b0d6c97f4aed
function Execute_Ressource2Salt()
	try
		Trp = Salt_Data[1]
		Qty = parse(Int64,Salt_Data[3])
		Ressource = Salt_Data[2]
		pr = Ressource2Salt(Troupes,Trp,Ressource,Qty)
		println(pr)
	catch
		pr = "Veuillez remplir les cases puis cliquer sur envoyer pour confirmer l'échange"
		println(pr)
	end
end

# ╔═╡ ec047408-2525-4947-bc4c-2df0ac126c7e
function Execute_Assault()
	try
		Att_Itgr = parse(Int64,Ass_Data[1])
		Def_Itgr = parse(Int64,Ass_Data[2])
		pr = Assault(World,Att_Itgr,Def_Itgr)
		println(pr)
	catch
		pr = "Veuillez remplir les cases puis cliquer sur envoyer pour confirmer l'attaque."
		println(pr)
	end
end

# ╔═╡ 3daf9148-39d2-493c-96be-307d1e402436
if Buy == true
	Execute_Buy()
elseif Turn == true
	Execute_NewTurn()
elseif Transfer == true
	Execute_Transfer()
elseif Salt == true
	Execute_Ressource2Salt()
elseif Ass == true
	Execute_Assault()
end

# ╔═╡ Cell order:
# ╠═c7e31109-3c17-4880-b870-6dd45eb29aa1
# ╟─b9b43e1a-fac4-403c-9bd7-02e9126f0ca8
# ╟─27d48cc9-69bb-49f1-8290-ac821e6f77d9
# ╟─9462050f-92ca-4c33-b1f8-afcc80ede3cf
# ╟─0e22a490-62b1-485b-80b6-6b046062ece8
# ╠═f29c16f1-b8a2-41d4-986b-4b83dec9032d
# ╟─ba82811c-91b4-4355-97ce-ea731c2000c9
# ╠═61fbec2c-1003-4ccf-a588-0f5b927226f1
# ╟─4f4b516e-00c6-4dc3-aee3-7fb8c1a1b8cf
# ╠═2bebe9c0-b5af-4336-825a-9add6581d21d
# ╟─1d6eba18-9d51-4c96-975d-bdc9c5d2e861
# ╟─60a165a8-4e65-4948-8fd7-d8c744051037
# ╠═0b8cd34c-02e7-4559-a687-bc1a8f020ddf
# ╠═933a08ef-df41-4f9d-b755-2f467dbad556
# ╟─03951448-2744-4668-a5c0-13a3cb57c8db
# ╟─2fa4706b-f1ca-4fa0-8568-b0512936d8b2
# ╟─000d6c33-dc9f-4ddb-8439-20d1a7a98d82
# ╟─5ebd7c4e-6dba-44dc-b4fe-8fcaf4f5b09c
# ╠═4e2210be-c52e-42b7-9bd8-3ed46e62a4e3
# ╟─28d3f46d-3258-4c9b-bffa-13d9f464cbd5
# ╟─abd800af-4f8f-48bb-9588-f43c75957605
# ╟─dc8eff81-5e94-4cb2-8e78-b822f307a120
# ╟─4782e4f3-a8ba-459e-8668-e82330ae7b0d
# ╟─25f01e6a-303f-45e9-b860-d53cb12c2525
# ╟─b04c0ee0-ec1d-4af1-ab36-2f3e1fdf918b
# ╟─51fdab25-7c05-432d-a388-7949cfeddb3e
# ╟─6ed6bcf1-4b61-4adf-ae18-22959bac3f1f
# ╟─57d50a15-7578-4348-bc38-5e4196bf26c6
# ╟─2194282d-5203-4d1d-965e-b40469064624
# ╟─f2a72f90-7841-4ccd-a09d-2c94f54476e8
# ╟─3ffe698b-10f7-4164-93f5-d9338775cc74
# ╟─6c0a40cd-d316-42bb-955a-00f2afdbefa0
# ╟─49d6deec-8929-4e17-9ba7-a23cec4de568
# ╟─554d8c87-8a34-4ca2-98ff-443dc8226381
# ╟─3d3cc7ed-cf7a-4b4f-98e9-95359ad21cef
# ╟─d45625d4-9e8f-4724-941e-e9b514a27651
# ╠═82ce8603-027a-4197-8d9e-d6c471e416ed
# ╠═7944dc39-3a02-4237-9833-54b5865c0e19
# ╠═b0b8944f-fa64-4cef-ad60-81b9371f38bb
# ╟─ac9c1cb6-78ad-4387-83c5-c83522f5bb6d
# ╟─4a58cec4-778c-4594-ae25-2492acddc68b
# ╟─15ccf590-a109-4e7f-aa5a-b756d6fccbe9
# ╟─2e77c3fc-94bd-4dfe-a8b9-4302db6b85fb
# ╠═3b763c2f-83d8-4be6-9fb5-e6ce1881db52
# ╠═1e15b72a-b0be-4045-961b-5e8de4cc9b4f
# ╠═ca705873-8374-4baa-a4c4-65d1ccdb5698
# ╠═a1b4005e-6e10-45ee-b018-6ff5c0a1a4a9
# ╠═8bb403e2-83e7-49b7-8c3c-b0d6c97f4aed
# ╠═31f0c518-740d-4d6b-be63-ee953d6f477b
# ╠═ec047408-2525-4947-bc4c-2df0ac126c7e
# ╠═3f554a7d-8d0c-4258-ab9e-2a88d41fdda1
# ╟─79b63986-ce3a-451e-be10-4bb90f76f93a
# ╟─018f1d80-9fbc-4d36-a41e-319c86511b76
# ╟─ce6b11f9-8230-4076-8135-12df833d4a82
# ╟─a0406049-10c0-4b93-9f0e-ac7eebe6d979
# ╟─400579f3-b212-4902-b96e-8659c33245da
# ╟─89a6d635-ff6d-44d3-b2f7-7f64bc12ea47
# ╟─91a757ac-e56c-4228-8cff-fbd25fa27714
# ╟─34d229fe-06af-4179-b44a-5c1208f86ff0
# ╟─e21132a8-c795-416d-90c1-d1817337af89
# ╟─55be7c75-ee34-4a2e-b02d-b69402f82672
# ╟─3daf9148-39d2-493c-96be-307d1e402436
