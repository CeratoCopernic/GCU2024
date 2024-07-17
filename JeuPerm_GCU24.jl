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
	using Plots
	#using Interact
	using PrettyTables
	#using Genie
	#using Observables
	#using GLMakie
	using Statistics
	using HypertextLiteral
	using DelimitedFiles #NEW
	using Dates # NEW
	TableOfContents()
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
	Sel::Float64
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
	const Fluv = [108,109,117,116,119,128,137,136,138,145,146,150,151,141,142,132,143,131,134,135,133,172,178,177,179,180,174,173,170,171,215,224,216,208,209,210,218,211,212,203,97,95,94,93,91,24,19,25,14,15,9,16,21,22,28,23,20] #Liste des territoires en bordure de fleuve
	const Capitals = [22,42,91,146,172,224]
	const Farm_Cost = [90 100 0 0] #Ordre : Bois, Pierre, Blé, Minerais
	const Mine_Cost = [90 100 0 0]
	const Saw_Cost = [90 100 0 0]
	const Carr_Cost = [90 100 0 0]
	const Boat_Cost = [400 0 0 5]
	const Sold_Cost = [0 0 0 10]
	const SoldEntr_Cost = [0 0 7 0]
	const Port_Cost = [175 225 0 75]
	const Start_Ressources = [1100 1100 1500 100]
	const Troupe_Names = ["Archers", "Hardis", "Paladins","Lanciers","Gueux","Preux","Vaillants","Chevaliers","Templiers","Servants","Autochtones"]
	const Catas = ["tropical rains","earthquakes","forest fires","tsunami","tornado","virus"]
	const World_Size = 246
	const Ref_Money = 500
	const Boat_Capacity = 10
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
		push!(Actors,Troupe(element,0,0,0,0,0,0,0,0))
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

# ╔═╡ 0b8cd34c-02e7-4559-a687-bc1a8f020ddf
"""
		World_Generator(Nbr_Terr)
	Cette fonction prend comme argument le nombre de territoires qui composent le monde et construit un vecteur (une liste) qui contient toutes les territoires (= cases) du monde. Par défaut, tous les territoires appartiennent aux autochtones
	"""
function World_Generator(Nbr_Terr)
	World_Matrix = []::Any
	for i in 1:Nbr_Terr
		push!(World_Matrix,Territoire(i,0,"Autochtones",0,0,0,0,0,0,false,false,false,false,false,false,false))
	end
	Coast_Terr(World_Matrix,Coast)
	Fluv_Terr(World_Matrix,Fluv)
	return World_Matrix
end

# ╔═╡ 4e2210be-c52e-42b7-9bd8-3ed46e62a4e3
"""
		Start_Game()
	Cette fonction sert à démarrer le jeu. Elle ne prend pas d'arguments, et retourne la matrice du monde et des joueurs telle qu'elle doit être en début de partie
	"""
function Start_Game()
	World_Matrix =  World_Generator(World_Size)
	Actors_Matrix = Actors_Generators()
	#Assignation des caractéristiques géographiques (cf. const)
	Fluv_Terr(World_Matrix,Fluv)
	Coast_Terr(World_Matrix,Coast)
	#Assignations des rentes aux territoires (cf. const)
	for i in 1:World_Size
		World_Matrix[i].Minerais = Min_Val[i]
		World_Matrix[i].Blé = Blé_Val[i]
		World_Matrix[i].Bois = Bois_Val[i]
		World_Matrix[i].Pierre = Pir_Val[i]
		World_Matrix[i].Type = Types_Val[i]
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
		Base_Terr.Soldats = 50
		Base_Terr.Bateaux = 5
		Base_Terr.Port = true
	end
	#Nombre d'autochtones
	for element in World_Matrix[1:236]
		if element.IsCoast == true && element.IsFluvial == true && element.CaseID ∉ Capitals
			element.Soldats = a = round((6+(element.Type-3))*rand(1)[1])+2+(element.Type-1) #Entre 3 et 13 (fct de la taille)
		elseif (element.IsCoast == false && element.IsFluvial == true) || (element.IsCoast == true && element.IsFluvial == false) && element.CaseID ∉ Capitals
			element.Soldats = a = round((5+(element.Type-4))*rand(1)[1])+1+(element.Type-1) #Entre 2 et 10
		elseif element.CaseID ∈ Capitals
			element.Soldats = 15+element.Type #Capitale : mauvais bail
			element.Ferme = true
			element.Mine = true
			element.Carrière = true
			element.Scierie = true
			element.Port = true
			element.Bateaux = round(2*rand(1)[1])+4
		else
			element.Soldats = round((4+(element.Type-4))*rand(1)[1])+1+(element.Type-1) #Entre 1 et 8
		end
	end
	#Parsemer des bâtiments
	for element in World_Matrix[1:236]
		if element ∉ Capitals
			factor = element.Soldats
			chances = []
			for i in 1:5
				a = floor(round((5+factor)*rand(1)[1])/10)
				if a > 0
					bool = true
				else
					bool = false
				end
				push!(chances,bool)
			end
			if chances[1] == true
				element.Ferme = true
			end
			if chances[2] == true
				element.Scierie = true
			end
			if chances[3] == true
				element.Carrière = true
			end
			if chances[4] == true
				element.Mine = true
			end
			if chances[5] == true && (element.IsCoast == true || element.IsFluvial == true)
				element.Port = true
				element.Bateaux = floor(round((17+2*factor)*rand(1)[1])/10)
			end
		end
	end
	#Donner le nécessaire aux autochtones
	Actors_Matrix[11].Bois = 1000*Start_Ressources[1]
	Actors_Matrix[11].Pierre = 1000*Start_Ressources[2]
	Actors_Matrix[11].Blé = 1000*Start_Ressources[3]
	Actors_Matrix[11].Minerais = 1000*Start_Ressources[4]
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
	for i in 1:Int(round(size(World_Matrix)[1]/5))
		World_Matrix[i].Troupe = rand(Troupe_Names)
	end
	return World_Matrix,Actors_Matrix
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

# ╔═╡ 085d3212-a58f-49e6-925c-2fd134ad8471
"""
		Is_SameContinent(World_Matrix,Terr1::Int,Terr2::Int)
	Cette fonction sert à vérifier si deux territoires appartiennent à un même contienent (sorry, elle est pas super joliment codée, mais elle fonctionne). Elle prend 3 arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- L'ID du territoire n°1
	- L'ID du territoire n°2
	Il renvoie un bool : `true` si les territoires appartiennent au même continent, ou `false` si ce n'est pas le cas.
	"""
function Is_SameContinent(World_Matrix,Terr1::Int,Terr2::Int)
	Iscont = false
	Cont1 = 0
	if Terr1 in C1
		Cont1 = "C1"
	elseif Terr1 in C0
		Cont1 = "C0"
	elseif Terr1 in C2
		Cont1 = "C2"
	elseif Terr1 in C3
		Cont1 = "C3"
	elseif Terr1 in C4
		Cont1 = "C4"
	elseif Terr1 in C5
		Cont1 = "C5"
	elseif Terr1 in C6
		Cont1 = "C6"
	elseif Terr1 in I1
		Cont1 = "I1"
	elseif Terr1 in I2
		Cont1 = "I2"
	elseif Terr1 in I3
		Cont1 = "I3"
	elseif Terr1 in I4
		Cont1 = "I4"
	elseif Terr1 in I5
		Cont1 = "I5"
	end
		
	if Terr2 in C1
		Cont2 = "C1"
	elseif Terr2 in C0
		Cont2 = "C0"
	elseif Terr2 in C2
		Cont2 = "C2"
	elseif Terr2 in C3
		Cont2 = "C3"
	elseif Terr2 in C4
		Cont2 = "C4"
	elseif Terr2 in C5
		Cont2 = "C5"
	elseif Terr2 in C6
		Cont2 = "C6"
	elseif Terr2 in I1
		Cont2 = "I1"
	elseif Terr2 in I2
		Cont2 = "I2"
	elseif Terr2 in I3
		Cont2 = "I3"
	elseif Terr2 in I4
		Cont2 = "I4"
	elseif Terr2 in I5
		Cont2 = "I5"
	end

	if Cont1 == Cont2
		Iscont = true
	end
	return Iscont
end

# ╔═╡ 88bf0967-64e5-4e4d-a891-374f52093b92
"""
		Give_Market_State(World_Matrix)
	Cette fonction sert de base à la détermination des taux de change des ressources. Elle prend un seul argument : 
	- Le vecteur qui contient tous les territoires composant le monde.
	Elle retourne un `tuple` de 4 éléments, qui correspondent chacun au pourcentage des ressources découvertes par rapport à ce qu'il y a au total dans le monde (ordre : minerais - blé - bois - pierre). 
	"""
function Give_Market_State(World_Matrix)
	Min_Aut = 0
	Blé_Aut = 0
	Bois_Aut = 0
	Pir_Aut = 0
	Min_Tot = 0
	Blé_Tot = 0
	Bois_Tot = 0
	Pir_Tot = 0
	for element in World_Matrix
		if element.Troupe == "Autochtones"
			Min_Aut += (0.8+2*element.Type/10)*element.Minerais
			Blé_Aut += (0.8+2*element.Type/10)*element.Blé
			Bois_Aut += (0.8+2*element.Type/10)*element.Bois
			Pir_Aut += (0.8+2*element.Type/10)*element.Pierre

			Min_Tot += (0.8+2*element.Type/10)*element.Minerais
			Blé_Tot += (0.8+2*element.Type/10)*element.Blé
			Bois_Tot += (0.8+2*element.Type/10)*element.Bois
			Pir_Tot += (0.8+2*element.Type/10)*element.Pierre
		else
			Min_Tot += (0.8+2*element.Type/10)*element.Minerais
			Blé_Tot += (0.8+2*element.Type/10)*element.Blé
			Bois_Tot += (0.8+2*element.Type/10)*element.Bois
			Pir_Tot += (0.8+2*element.Type/10)*element.Pierre
		end
	end
	Min_Disc_frac = 1-Min_Aut/Min_Tot
	Blé_Disc_frac = 1-Blé_Aut/Blé_Tot
	Bois_Disc_frac = 1-Bois_Aut/Bois_Tot
	Pir_Disc_frac = 1-Pir_Aut/Pir_Tot
	return Min_Disc_frac,Blé_Disc_frac,Bois_Disc_frac,Pir_Disc_frac
end

# ╔═╡ ce1c8eb9-4ad7-4bb6-ac51-394cd187854a
"""
		Select_Catastrophee_Terr(World_Matrix,size)
	Cette fonction sert à désigner les territoires qui subirtont une catastrophe. Elle prend deux arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le nombre de territoires par continent qui seront touchés pr la catstrophes. Les catstrophes s'appliquent à une certaine région donnée (territoires successifs)
	Elle retourne une liste qui contient les numéros d'identité des territoires impliqués.
	"""
function Select_Catastrophee_Terr(World_Matrix,size)
	Continents = [C1,C2,C3,C4,C5,C6]
	Selected_Cont1 = rand(Continents)
	Selected_Cont2 = rand(Continents)
	while Selected_Cont1 == Selected_Cont2
		Selected_Cont2 = rand(Continents)
	end
	Selected_Conts = [Selected_Cont1,Selected_Cont2]
	Terrs = []
	for i in 1:2
		Terr = rand(Selected_Conts[i])
		for j in 1:size
			push!(Terrs,Terr+j)
		end
	end
	return Terrs
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
	Actor_Strct = Find_Troup(Actor,Actors_Matrix)
	ID = Terr.CaseID
	Data = Assign_MilQties(World_Matrix,Actors_Matrix,Actor::String)
	Cost = [0 0 0 0]
	Trp_Fortuna = [Actor_Strct.Bois Actor_Strct.Pierre Actor_Strct.Blé Actor_Strct.Minerais]
	Executable = false
	if Entity == "Ferme"
		Cost = Farm_Cost
		if all(Trp_Fortuna .>= Cost) == true
			if Terr.Ferme == false
				Terr.Ferme = true
				Executable = true
				pr = "Achat effectué : Les $Actor ont construit une ferme sur le territoire n°$ID."
			elseif Terr.Ferme == true
				pr = "Achat non effectué : Le territoire contient déjà une ferme."
			end
		else
			pr = "Achat non effectué : Les $Actor n'ont pas assez de ressources pour acheter une ferme.\n\nCOÛT D'UNE FERME :                                 RESSOURCES DES $(uppercase(Actor)) :\nBlé : $(Cost[3])                                            Blé : $(round(Actor_Strct.Blé))\nBois : $(Cost[1])                                          Bois : $(round(Actor_Strct.Bois))\nPierre : $(Cost[2])                                       Pierre : $(round(Actor_Strct.Pierre))\nMinerais : $(Cost[4])                                       Minerais : $(round(Actor_Strct.Minerais))"
		end
	elseif Entity == "Scierie"
		Cost = Saw_Cost
		if all(Trp_Fortuna .>= Cost) == true
			if Terr.Scierie == false
				Terr.Scierie = true
				Executable = true
				pr = "Achat effectué : Les $Actor ont construit une scierie sur le territoire n°$ID."
			elseif Terr.Scierie == true
				pr = "Achat non effectué : Le territoire contient déjà une sciereie."
			end
		else
			pr = "Achat non effectué : Les $Actor n'ont pas assez de ressources pour acheter une scierie.\n\nCOÛT D'UNE SCIERIE :                               RESSOURCES DES $(uppercase(Actor)) :\nBlé : $(Cost[3])                                            Blé : $(round(Actor_Strct.Blé))\nBois : $(Cost[1])                                          Bois : $(round(Actor_Strct.Bois))\nPierre : $(Cost[2])                                       Pierre : $(round(Actor_Strct.Pierre))\nMinerais : $(Cost[4])                                       Minerais : $(round(Actor_Strct.Minerais))"
		end
	elseif Entity == "Carrière"
		Cost = Carr_Cost
		if all(Trp_Fortuna .>= Cost) == true
			if Terr.Carrière == false
				Terr.Carrière = true
				Executable = true
				pr = "Achat effectué : Les $Actor ont construit une carrière sur le territoire n°$ID."
			elseif Terr.Carrière == true
				pr = "Achat non effectué : Le territoire contient déjà une carrière."
			end
		else
			pr = "Achat non effectué : Les $Actor n'ont pas assez de ressources pour acheter une carrière.\n\nCOÛT D'UNE CARRIÈRE :                              RESSOURCES DES $(uppercase(Actor)) :\nBlé : $(Cost[3])                                            Blé : $(round(Actor_Strct.Blé))\nBois : $(Cost[1])                                          Bois : $(round(Actor_Strct.Bois))\nPierre : $(Cost[2])                                       Pierre : $(round(Actor_Strct.Pierre))\nMinerais : $(Cost[4])                                       Minerais : $(round(Actor_Strct.Minerais))"
		end
	elseif Entity == "Mine"
		Cost = Mine_Cost
		if all(Trp_Fortuna .>= Cost) == true
			if Terr.Mine == false
				Terr.Mine = true
				Executable = true
				pr = "Achat effectué : Les $Actor ont construit une mine sur le territoire n°$ID."
			elseif Terr.Mine == true
				pr = "Achat non effectué : Le territoire contient déjà une mine."
			end
		else
			pr = "Achat non effectué : Les $Actor n'ont pas assez de ressources pour acheter une mine.\n\nCOÛT D'UNE MINE :                                  RESSOURCES DES $(uppercase(Actor)) :\nBlé : $(Cost[3])                                            Blé : $(round(Actor_Strct.Blé))\nBois : $(Cost[1])                                          Bois : $(round(Actor_Strct.Bois))\nPierre : $(Cost[2])                                       Pierre : $(round(Actor_Strct.Pierre))\nMinerais : $(Cost[4])                                       Minerais : $(round(Actor_Strct.Minerais))"
		end
	elseif Entity == "Port"
		Cost = Port_Cost
		if all(Trp_Fortuna .>= Cost) == true
			if Terr.Port == false
				Terr.Port = true
				Executable = true
				pr = "Achat effectué : Les $Actor ont construit un port sur le territoire n°$ID."
			elseif Terr.Port == true
				pr = "Achat non effectué : Le territoire contient déjà un port."
			end
		else
			pr = "Achat non effectué : Les $Actor n'ont pas assez de ressources pour acheter un port.\n\nCOÛT D'UN PORT :                                   RESSOURCES DES $(uppercase(Actor)) :\nBlé : $(Cost[3])                                            Blé : $(round(Actor_Strct.Blé))\nBois : $(Cost[1])                                         Bois : $(round(Actor_Strct.Bois))\nPierre : $(Cost[2])                                       Pierre : $(round(Actor_Strct.Pierre))\nMinerais : $(Cost[4])                                      Minerais : $(round(Actor_Strct.Minerais))"
		end
	elseif Entity == "Bateau"
		Cost = Boat_Cost
		if all(Trp_Fortuna .>= Cost) == true
			Terr.Bateaux = Terr.Bateaux+1
			Executable = true
			pr = "Achat effectué : Les $Actor ont ajouté un bâteau sur le territoire n°$ID."
		else
			pr = "Achat non effectué : Les $Actor n'ont pas assez de ressources pour acheter un bateau."
		end
	elseif Entity == "Soldat"
		Cost = Sold_Cost
		if all(Trp_Fortuna .>= Cost) == true
			Terr.Soldats = Terr.Soldats+1
			Executable = true
			pr = "Achat effectué : Les $Actor ont ajouté un soldat sur le territoire n°$ID."
		else
			pr = "Achat non effectué : Les $Actor n'ont pas assez de ressources pour acheter un soldat."
		end
	end
	#Ordre de la matrice Cost : Bois, Pierre, Blé, Minerais
	if Executable == true
		Data.Bois = Data.Bois-Cost[1]
		Data.Pierre = Data.Pierre-Cost[2]
		Data.Blé = Data.Blé-Cost[3]
		Data.Minerais = Data.Minerais-Cost[4]
	end
	return pr
end

# ╔═╡ f209d063-9403-4578-8fd8-f521f97089d6
"""
		Add_Mil_Entities(World_Matrix,Actors_Matrix,Trp::String,Entity::String,Qty,Terr)
	Cette fonction permet d'acheter plusieurs bâteaux/soldats à la fois. Elle prend 5 arguments :
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le vecteur qui contient tous les joueurs ;
	- La troupe qui souhaite effectuer l'achat ;
	- L'unité qui doit être achetée (`"Soldat"` ou `"Bateau"`);
	- La quantité d'unités à acheter
	Elle effectue les changements nécessaires dans le jeu et retourne un message qui renseigne l'état de l'achat.
	"""
function Add_Mil_Entities(World_Matrix,Actors_Matrix,Trp::String,Entity::String,Qty,Terr)
	Trp_Strct = Find_Troup(Trp,Actors_Matrix)
	Terr_Strct = Find_Terr(Terr,World_Matrix)
	Prp = Properties(World_Matrix,Trp)
	Mat = []
	Executable = true
	for element in Prp
		elm = Find_Terr(element,World_Matrix)
		if elm.Type == 0
			push!(Mat,elm)
		end
	end

	imat = []
	for i in 1:Qty
		ppr = Add_Entity(World_Matrix,Actors_Matrix,Terr_Strct,Entity)
		if startswith(ppr, "Achat effectué")
			push!(imat,i)
		else
			Executable = false
			break
		end
	end
	#else
		#Spawn_Terr = Mat[1]
		#imat = []
		#for i in 1:Qty
			#ppr = Add_Entity(World_Matrix,Actors_Matrix,Spawn_Terr,Entity)
			#if startswith(ppr, "Achat effectué")
				#push!(imat,i)
			#else
				#Executable = false
				#break
			#end
		#end
	
	if Entity == "Soldat"
		char = "s"
	else
		char = "x"
	end
	
	effective_adds = length(imat)
	if effective_adds == 0
		pr = "Achat non-effectué : les $Trp ne possèdent pas assez de ressources pour acheter des $(lowercase(Entity))$char."
	elseif effective_adds < Qty
		pr = "Achat partiellement effectué : les $Trp ne possédaient pas suffisemment de ressources pour l'achat de $Qty $(lowercase(Entity))$char. Seuls $effective_adds $(lowercase(Entity))$char ont donc été achetés. Ils se situent sur le territoire n°$(Terr_Strct.CaseID)."
	else
		pr = "Achat effectué : Les $Trp ont acheté $effective_adds $(lowercase(Entity))$char. Ils se situent sur le territoire n°$(Terr_Strct.CaseID)."
	end
	return pr
end

# ╔═╡ 3ffe698b-10f7-4164-93f5-d9338775cc74
"""
		Transfer_Troups(World_Matrix,TerrInit,TerrDest,Nbr)
Cette sert à transférer des souldats d'un territoire à un autre. Elle prend 4 arguments : 
- Le vecteur qui contient tous les territoires composant le monde ;
- La structure `Territoire` du territoire de départ (où les troupes se situent initialement) ;
- La structure `Territoire` du territoire de destination (où les troupes désirent être déplacées) ;
- Le nombre de troupes su'il faudrait déplacer.
Elle retourne un message qui traduit le statut d'exécution de la fonction. Le programme vérifie également que les ports et les bateaux nécessaires ont été construits sur les territoires mentionnés. Si ce n'est pas le cas, elle renvoie un message qui informe le joueur sur la situation. 
	"""
function Transfer_Troups(World_Matrix,TerrInit::Territoire,TerrDest::Territoire,Nbr)
	if TerrInit.Troupe == TerrDest.Troupe
		IsCont = Is_SameContinent(World_Matrix,TerrInit.CaseID,TerrDest.CaseID)
		Boats_Init = TerrInit.Bateaux
		Trp = TerrInit.Troupe
		Terr_it = TerrInit.CaseID
		Terr_dt = TerrDest.CaseID
		if IsCont == true
			if TerrInit.Soldats > Nbr
				TerrInit.Soldats = TerrInit.Soldats-Nbr
				TerrDest.Soldats = TerrDest.Soldats+Nbr
				pr = "Transfert effectué : $Nbr Soldats ont été transférés du territoire n°$Terr_it vers le territoire n°$Terr_dt par les $Trp"
			elseif TerrInit.Soldats == Nbr
				pr = "Transfert impossible : vous devez au moins garder un soldat sur le territoire n°$(Terr_it) pour pouvoir l'occuper"
			else
				pr = "Transfert impossible : vous n'avez pas assez de soldats sur le territoire n°$(Terr_it)"
			end
		elseif IsCont == false && (TerrInit.IsCoast == false && TerrInit.IsFluvial == false) || (TerrDest.IsCoast == false && TerrDest.IsFluvial == false)
			pr = "Transfert intercontinental impossible : les territoires n°$(Terr_it) et n°$(Terr_dt) doivent tous les deux être soit fluviaux, soit côtiers."
		elseif IsCont == false && (TerrInit.IsCoast == true || TerrInit.IsFluvial == true) && (TerrDest.IsCoast == true || TerrDest.IsFluvial == true)
			if TerrInit.Port == false && TerrDest.Port == false
				pr = "Transfert intercontinental impossible : Vous n'avez de ports sur aucun des deux territoires ($Terr_it et $Terr_dt)"
			elseif TerrInit.Port == false && TerrDest.Port == true
				pr = "Transfert intercontinental impossible : Vous n'avez pas de port sur le territoire n°$Terr_it."
			elseif TerrDest.Port == false && TerrInit.Port == true
				pr = "Transfert intercontinental impossible : Vous n'avez pas de port sur le territoire n°$Terr_dt."
			elseif TerrInit.Port == true && TerrDest.Port == true
				if Nbr ≤ Boat_Capacity*Boats_Init
					Used_Boats = ceil(Nbr/Boat_Capacity)
					if TerrInit.Soldats > Nbr
						TerrInit.Soldats = TerrInit.Soldats-Nbr
						TerrDest.Soldats = TerrDest.Soldats+Nbr
						#TerrInit.Bateaux = TerrInit.Bateaux-Used_Boats
						#TerrDest.Bateaux = TerrDest.Bateaux+Used_Boats
						pr = "Transfert intercontinental effectué : $Nbr Soldats ont été transférés du territoire n°$Terr_it avec $Used_Boats bateau(x) vers le territoire n°$Terr_dt par les $Trp"
					elseif TerrInit.Soldats == Nbr
						pr = "Transfert impossible : vous devez au moins garder un soldat sur le territoire n°$(Terr_it) pour pouvoir l'occuper"
					else
						pr = "Transfert impossible : vous n'avez pas assez de soldats sur le territoire n°$(Terr_it)"
					end
				elseif Boats_Init == 0
					pr = "Transfert intercontinental impossible : construisez d'abord des bateaux sur le territoire n°$(Terr_it) !"
				elseif Nbr > Boat_Capacity*Boats_Init
					Tf_max = Boat_Capacity*Boats_Init
					pr = "Transfert intercontinental impossible : Un bateau ne peut contenir que $Boat_Capacity soldats maximum. Vous essayez de tranférer $Nbr soldats, mais vous ne possédez que de $Boats_Init bateaux... A moins de construire des bateaux supplémentaires, vous ne pouvez tranférer que maximum $Tf_max soldats."
				end
			end
		else
			pr = "Other error"
		end
	else
		pr = "Transfert impossible : Vous devez choisir des territoires qui vous appartiennent."
	end
	return pr
end
#Note : ne vérifie pas si les territoires sont adjacents...

# ╔═╡ fbd3a901-c2b2-4e3f-8610-2da7a12c7b13
"""
		Spread_Soldiers(World_Matrix,Actors_Matrix,Trp,Terrsinit,Terrsend)
	Cette fonction permet de répartir équitable toutes les troupes se trouvant sur un territoire sur plusieurs autres territoires. Elle prend 5 arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le vecteur qui contient tous les joueurs ;
	- Le nom de la troupe qui souhaite effectuer les transferts ;
	- Le numéro d'identité du territoire de départ ;
	- Une liste contenant les numéros d'identité des territoires d'arrivée.
	Elle effectue tous les changement snécessaires dans le jeu et retourne un message par transfert, qui renseigne sur létat du transfert. Quelques remarques : 
	- Il est possible de mettre le territoire de départ dans la liste des territoires d'arrivée (au cas où le joueur souhaite laisser des troupes sur le territoire de départ);
	- Ce n'est pas parce que l'un des transferts est impossible que les autres transferts n'ont pas lieu ! Donc le joueur doit veiller à ce que tout soit correct dès le départ, s'il ne veut pas perdre de temps.
	"""
function Spread_Soldiers(World_Matrix,Actors_Matrix,Trp,Terrsinit,Terrsend)
	Terrsinit_Strct = Find_Terr(Terrsinit,World_Matrix)
	Terrsend_Strct = []
	error = false
	if Terrsinit_Strct.Troupe ≠ Trp
		error = true
	end
	for element in Terrsend
		TS = Find_Terr(element,World_Matrix)
		if TS.Troupe == Trp
			push!(Terrsend_Strct,TS)
		else
			error = true
		end
	end

	if error == true
		pr = "Transfert impossible : au moins un des territoires sélectionné ne vous appartient pas."
	else
		Tot_Soldats = Terrsinit_Strct.Soldats-1
		nbr_terrend = length(Terrsend_Strct)
		Rest = Tot_Soldats % nbr_terrend
		Soldiers_to_move = (Tot_Soldats-Rest)/nbr_terrend
		if Soldiers_to_move == 0
			pr = "Transferts impossibles : Vous n'avez pas assez de soldats sur le territoire n°$Terrsinit."
		else
			pr = []
			for element in Terrsend_Strct
				ppr = Transfer_Troups(World_Matrix,Terrsinit_Strct,element,Soldiers_to_move)
				push!(pr,ppr)
			end
		end
	end
		
	return pr
end

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
function Ressource2Salt(World_Matrix,Actors_Matrix,Troupe::String,Ressource::String,Quantity)
	# Quantity doit être exprimée en grammes
	Min_Disc_frac,Blé_Disc_frac,Bois_Disc_frac,Pir_Disc_frac = Give_Market_State(World_Matrix)
	Trp = Find_Troup(Troupe,Actors_Matrix)
	if Ressource == "Blé"
		Cost = Quantity
		Salt_obtnd = Quantity/35
		if Trp.Blé >= Cost
			Trp.Blé = Trp.Blé-Cost
			Trp.Sel += Salt_obtnd
			pr = "Les $Troupe viennent d'échanger $Quantity unités de blé contre $(round(Salt_obtnd*100)/100) grammes de sel"
		else
			pr = "Les $Troupe n'ont pas assez de $Ressource pour effectuer cet échange"
		end
	elseif Ressource == "Pierre"
		beta = Pir_Disc_frac/Blé_Disc_frac
		Cost = Quantity
		Salt_obtnd = (Quantity/35)*beta
		if Trp.Pierre >= Cost
			Trp.Pierre = Trp.Pierre-Cost
			Trp.Sel += Salt_obtnd
			pr = "Les $Troupe viennent d'échanger $Quantity unités de pierre contre $(round(Salt_obtnd*100)/100) grammes de sel"
		else
			pr = "Les $Troupe n'ont pas assez de $Ressource pour effectuer cet échange"
		end
	elseif Ressource == "Minerais"
		beta = Min_Disc_frac/Blé_Disc_frac
		Cost = Quantity
		Salt_obtnd = (Quantity/35)*beta
		if Trp.Minerais >= Cost
			Trp.Minerais = Trp.Minerais-Cost
			Trp.Sel += Salt_obtnd
			pr = "Les $Troupe viennent d'échanger $Quantity unités de minerais contre $(round(Salt_obtnd*100)/100) grammes de sel"
		else
			pr = "Les $Troupe n'ont pas assez de $Ressource pour effectuer cet échange"
		end
	elseif Ressource == "Bois"
		beta = Bois_Disc_frac/Blé_Disc_frac
		Cost = Quantity
		Salt_obtnd = (Quantity/35)*beta
		if Trp.Bois >= Cost
			Trp.Bois = Trp.Bois-Cost
			Trp.Sel += Salt_obtnd
			pr = "Les $Troupe viennent d'échanger $Quantity unités de bois contre $(round(Salt_obtnd*100)/100) grammes de sel"
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
		New_Turn(World_Matrix,Actors_Matrix,SaltPerc)
Cette fonction exécute un nouveau tour. Elle prend 2 arguments : 
- Le vecteur qui contient tous les territoires composant le monde ;
- Le vecteur qui contient tous les joueurs ;
Elle retourne un texte qui informe de ;la quantité de sel qui doit être donnée à chaque troupe, et exécute les actions suivantes : 
- Verse à chaque troupe les rentes de leurs territoires respectifs ;
- Retire à chaque troupe la quantité de blé nécessaire pour entretenir son armée. Si la quantité de blé est insuffisante, la quantité de blé est mise à 0 et la troupe perd 1/3 de ses effectifs sur tous ses territoires (encore à implémenter : ne marche pas pour le moment). Une catastrophe naturelle se produit à chaque tour. le rapports sont automatiquemet enregistrés dans le PC (moyennant l'exécution des deux codes Py)
	"""
function New_Turn(World_Matrix,Actors_Matrix)
	Salt_Info = []
	for Trp in Actors_Matrix
		Prop = Properties(World_Matrix,Trp.Nom)
		Sizes = 0
		for i = 1:size(Prop)[1]
			CaseID = Prop[i]
			Terr = World_Matrix[CaseID]
			if Terr.Ferme == true
				Trp.Blé += 2*(0.8+2*Terr.Type/10)*Terr.Blé
			else
				Trp.Blé += (0.8+2*Terr.Type/10)*Terr.Blé
			end
			if Terr.Scierie == true
				Trp.Bois += 2*(0.8+2*Terr.Type/10)*Terr.Bois
			else
				Trp.Bois += (0.8+2*Terr.Type/10)*Terr.Bois
			end
			if Terr.Carrière == true
				Trp.Pierre += 2*(0.8+2*Terr.Type/10)*Terr.Pierre
			else
				Trp.Pierre += (0.8+2*Terr.Type/10)*Terr.Pierre
			end
			if Terr.Mine == true
				Trp.Minerais += 2*(0.8+2*Terr.Type/10)*Terr.Minerais
			else
				Trp.Minerais += (0.8+2*Terr.Type/10)*Terr.Minerais
			end
			Sizes += Terr.Type
			if Terr.IsCoast == true 
				Sizes += 0.7
			end
			if Terr.IsFluvial == true
				Sizes += 0.3
			end
		end
		Sizes = round(Sizes)
		Trp.Sel += 2*Sizes
		ppr = "$(Trp.Nom) : $(2*Sizes) grammes de sel"
		push!(Salt_Info, ppr)
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
	for Terr in World_Matrix
		if Terr.Type == 0
			Terr.Soldats += 30
		end
	end
	pr = "Le tour a bien été effectué. Une catastrophe naturelle a eu lieu et les rapports correspondant ont été générés. Les rentes de sel à verser sont les suivantes\n\n$(Salt_Info[1])\n$(Salt_Info[2])\n$(Salt_Info[3])\n$(Salt_Info[4])\n$(Salt_Info[5])\n$(Salt_Info[6])\n$(Salt_Info[7])\n$(Salt_Info[8])\n$(Salt_Info[9])\n$(Salt_Info[10])"
	return pr
end

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
	IsCont = Is_SameContinent(World_Matrix,Att_Terr_Int,Def_Terr_Int)
	Att_Terr = Find_Terr(Att_Terr_Int,World_Matrix)
	Def_Terr = Find_Terr(Def_Terr_Int,World_Matrix)
	if IsCont == true
		Att_nbr = Int(Att_Terr.Soldats)
		#Att_nbr = Int(Att_Terr.Soldats)
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
				pr = "DÉFAITE...\n\nLes $Def_Trp ont réussi à défendre leur territoire! Il leur reste $Def_nbr_rest soldats sur leur territoire. Toutes les troupes des $Att_Trp sont tombées au combat... Seul 1 soldat reste sur le territoire $Att_Terr_Int.\n\nPERTES DE L'ATTAQUANT : $(Att_nbr-Att_nbr_rest)                               PERTES DU DEFENSEUR :$(Def_nbr-Def_nbr_rest)"
			elseif Def_nbr_rest == 0 #Si l'attaque gagne
				Att_Terr.Soldats = 1
				Def_Terr.Troupe = Att_Trp
		    	Def_Terr.Soldats = Att_nbr_rest-1
				pr = "VICTOIRE !!\n\nLes $Att_Trp ont vaincu la défense des $Def_Trp, qui ont perdu toutes leurs troupes au combat ! Les $Att_Trp occupent donc maintenant le territoire numéro $Def_Terr_Int avec $(Att_nbr_rest-1) soldats. 1 soldat est resté défendre le territoire $Att_Terr_Int.\n\nPERTES DE L'ATTAQUANT : $(Att_nbr-Att_nbr_rest)                               PERTES DU DEFENSEUR : $(Def_nbr-Def_nbr_rest)"
			else
				println("Erreur 404")
			end
		end
	#Si pas même continenet et pas de port
	elseif IsCont == false && Att_Terr.Port == false
		pr = "Attaque impossible : vous devez d'abord construire un port sur le territoire d'où part l'attaque si une traversée de la mer est néecessaire"
	#Si pas même contienent mais port
	elseif IsCont == false && Att_Terr.Port == true
		#Si suffisamment de bateaux pour transporter toutes les troupes
		if Att_Terr.Bateaux ≥ (Att_Terr.Soldats-1)/Boat_Capacity
			Needed_Boats = ceil((Att_Terr.Soldats-1)/Boat_Capacity)
			Att_nbr = Int(Att_Terr.Soldats)
			#Att_nbr = Int(Att_Terr.Soldats)
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
					Def_Terr.Bateaux = Def_Terr.Bateaux + Needed_Boats
					Att_Terr.Bateaux = Att_Terr.Bateaux - Needed_Boats
					pr = "DÉFAITE...\n\nLes $Def_Trp ont réussi à défendre leur territoire! Il leur reste $Def_nbr_rest soldats sur leur territoire. Toutes les troupes des $Att_Trp sont tombées au combat... Seul 1 soldat reste sur le territoire $Att_Terr_Int.\n\nPERTES DE L'ATTAQUANT : $(Att_nbr-Att_nbr_rest)                               PERTES DU DEFENSEUR : $(Def_nbr-Def_nbr_rest)"
				elseif Def_nbr_rest == 0 #Si l'attaque gagne
					Att_Terr.Soldats = 1
					Def_Terr.Troupe = Att_Trp
			    	Def_Terr.Soldats = Att_nbr_rest-1
					Def_Terr.Bateaux = Def_Terr.Bateaux + Needed_Boats
					Att_Terr.Bateaux = Att_Terr.Bateaux - Needed_Boats
					pr = "VICTOIRE !!\n\nLes $Att_Trp ont vaincu la défense des $Def_Trp, qui ont perdu toutes leurs troupes au combat ! Les $Att_Trp occupent donc maintenant le territoire numéro $Def_Terr_Int avec $(Att_nbr_rest-1) soldats. 1 soldat est resté défendre le territoire $Att_Terr_Int.\n\nPERTES DE L'ATTAQUANT : $(Att_nbr-Att_nbr_rest)                               PERTES DU DEFENSEUR : $(Def_nbr-Def_nbr_rest)"
				else
					println("Erreur 404")
				end
			end
		#Si pas de bateaux du tout
		elseif Att_Terr.Bateaux == 0
			pr = "Attaque impossible : cette attaque nécessite une traversée de la mer! Construisez un ou plusieurs bateau(x) dans votre port avant de lancer l'expédition !"
		#Si pas assez de bâteaux pour transporter toutes les troupes
		elseif Att_Terr.Bateaux < (Att_Terr.Soldats-1)/Boat_Capacity
			Def_nbr_left = Att_Terr.Soldats-Int(Att_Terr.Bateaux*Boat_Capacity)
			Needed_Boats = Att_Terr.Bateaux
			Att_nbr = Int(Att_Terr.Bateaux*Boat_Capacity)
			#Att_nbr = Int(Att_Terr.Soldats)
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
					Def_Terr.Soldats = Def_nbr_rest
					Def_Terr.Bateaux = Def_Terr.Bateaux + Needed_Boats
					Att_Terr.Bateaux = Att_Terr.Bateaux - Needed_Boats
					Att_Terr.Soldats = Def_nbr_left
					pr = "DÉFAITE...\n\nLes $Def_Trp ont réussi à défendre leur territoire! Il leur reste $Def_nbr_rest soldats sur leur territoire. Toutes les troupes des $Att_Trp sont tombées au combat... Seuls $Def_nbr_left soldats restent sur le territoire $Att_Terr_Int (manque de bâteaux).\n\nPERTES DE L'ATTAQUANT : $(Att_nbr-Att_nbr_rest)                               PERTES DU DEFENSEUR : $(Def_nbr-Def_nbr_rest)"
				elseif Def_nbr_rest == 0 #Si l'attaque gagne
					Att_Terr.Soldats = 1
					Def_Terr.Troupe = Att_Trp
			    	Def_Terr.Soldats = Att_nbr_rest-1
					Def_Terr.Bateaux = Def_Terr.Bateaux + Needed_Boats
					Att_Terr.Bateaux = Att_Terr.Bateaux - Needed_Boats
					Att_Terr.Soldats = Def_nbr_left
					pr = "VICTOIRE !! \n\nLes $Att_Trp ont vaincu la défense des $Def_Trp, qui ont perdu toutes leurs troupes au combat ! Les $Att_Trp occupent donc maintenant le territoire numéro $Def_Terr_Int avec $(Att_nbr_rest-1) soldats. $Def_nbr_left soldats sont restés défendre le territoire $Att_Terr_Int (manque de bateaux).\n\nPERTES DE L'ATTAQUANT : $(Att_nbr-Att_nbr_rest)                               PERTES DU DEFENSEUR : $(Def_nbr-Def_nbr_rest)"
				else
					pr = "Erreur 404"
				end
			end
		else pr = "Erreur : Compris qu'il y a port, mais pas trouvé de sous-conndition..."
		end
	end
	return pr
end

# ╔═╡ 5882f6dc-0e89-418a-897b-921d233e74e8
"""
		Exchange_Ressources(World_Matrix,Actors_Matrix,Trp,Ress1,Ress2,Qty)
	Cette fonction permet à une troupe d'échanger des ressources avec la trésorerie du royaume, en tenant compte de la valeur boursière des différentes ressources. Elle prend 6 arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le vecteur qui contient tous les joueurs ;
	- Le nom de la troupe qui souhaite effectuer l'échange ;
	- Le type de ressource qu'elle souhaite vendre ;
	- Le type de ressource qu'elle souhaite recvoir en échange ;
	- La quantité de ressource qu'elle souhaite vendre.
	Elle effectue toutes les modifications nécessaires dans le jeu, et retourne un message qui donne un feedback sur ce qu'elle a effectué. Un taxe de 21% est prélevée sur chaque échange
	"""
function Exchange_Ressources(World_Matrix,Actors_Matrix,Trp::String,Ress1::String,Ress2::String,Qty)
	Trp_Strct = Find_Troup(Trp,Actors_Matrix)
	Min_Disc_frac,Blé_Disc_frac,Bois_Disc_frac,Pir_Disc_frac = Give_Market_State(World_Matrix)
	Bois_Start = Start_Ressources[1]
	Pir_Start = Start_Ressources[2]
	Blé_Start = Start_Ressources[3]
	Min_Start = Start_Ressources[4]
	if lowercase(Ress1) == "blé" && Trp_Strct.Blé ≥ Qty
		if lowercase(Ress2) == "bois" 
			#alpha = Bois_Start/Blé_Start #ce qu'elle reçoit/ce qu'elle donne
			beta = Bois_Disc_frac/Blé_Disc_frac
			#Taux = alpha*beta
			Qty_got = beta*Qty
			Trp_Strct.Blé -= Qty
			Trp_Strct.Bois += Qty_got*0.79
			pr = "Échange effectué (avec un taux de change de $(round(beta*10000)/100)% et une taxe de 21%). Les $Trp ont donc échangé $Qty unités de $Ress1 contre $(Qty_got*0.79) unités de $Ress2. "
		elseif lowercase(Ress2) == "pierre"
			#alpha = Pir_Start/Blé_Start #ce qu'elle reçoit/ce qu'elle donne
			beta = Pir_Disc_frac/Blé_Disc_frac
			#Taux = alpha*beta
			Qty_got = beta*Qty
			Trp_Strct.Blé -= Qty
			Trp_Strct.Pierre += Qty_got*0.79
			pr = "Échange effectué (avec un taux de change de $(round(beta*10000)/100)% et une taxe de 21%). Les $Trp ont donc échangé $Qty unités de $Ress1 contre $(Qty_got*0.79) unités de $Ress2. "
		elseif lowercase(Ress2) == "minerais"
			#alpha = Min_Start/Blé_Start #ce qu'elle reçoit/ce qu'elle donne
			beta = Min_Disc_frac/Blé_Disc_frac
			#Taux = alpha*beta
			Qty_got = beta*Qty
			Trp_Strct.Blé -= Qty
			Trp_Strct.Minerais += Qty_got*0.79
			pr = "Échange effectué (avec un taux de change de $(round(beta*10000)/100)% et une taxe de 21%). Les $Trp ont donc échangé $Qty unités de $Ress1 contre $(Qty_got*0.79) unités de $Ress2. "
		end
	elseif lowercase(Ress1) == "bois" && Trp_Strct.Bois ≥ Qty
		if lowercase(Ress2) == "blé" 
			#alpha = Blé_Start/Bois_Start #ce qu'elle reçoit/ce qu'elle donne
			beta = Blé_Disc_frac/Bois_Disc_frac
			#Taux = alpha*beta
			Qty_got = beta*Qty
			Trp_Strct.Bois -= Qty
			Trp_Strct.Blé += Qty_got*0.79
			pr = "Échange effectué (avec un taux de change de $(round(beta*10000)/100)% et une taxe de 21%). Les $Trp ont donc échangé $Qty unités de $Ress1 contre $(Qty_got*0.79) unités de $Ress2. "
		elseif lowercase(Ress2) == "pierre"
			#alpha = Pir_Start/Bois_Start #ce qu'elle reçoit/ce qu'elle donne
			beta = Pir_Disc_frac/Bois_Disc_frac
			#Taux = alpha*beta
			Qty_got = beta*Qty
			Trp_Strct.Bois -= Qty
			Trp_Strct.Pierre += Qty_got*0.79
			pr = "Échange effectué (avec un taux de change de $(round(beta*10000)/100)% et une taxe de 21%). Les $Trp ont donc échangé $Qty unités de $Ress1 contre $(Qty_got*0.79) unités de $Ress2. "
		elseif lowercase(Ress2) == "minerais"
			#alpha = Min_Start/Bois_Start #ce qu'elle reçoit/ce qu'elle donne
			beta = Min_Disc_frac/Bois_Disc_frac
			#Taux = alpha*beta
			Qty_got = beta*Qty
			Trp_Strct.Bois -= Qty
			Trp_Strct.Minerais += Qty_got*0.79
			pr = "Échange effectué (avec un taux de change de $(round(beta*10000)/100)% et une taxe de 21%). Les $Trp ont donc échangé $Qty unités de $Ress1 contre $(Qty_got*0.79) unités de $Ress2. "
		end
	elseif lowercase(Ress1) == "pierre" && Trp_Strct.Pierre ≥ Qty
		if lowercase(Ress2) == "blé" 
			#alpha = Blé_Start/Pir_Start #ce qu'elle reçoit/ce qu'elle donne
			beta = Blé_Disc_frac/Pir_Disc_frac
			#Taux = alpha*beta
			Qty_got = beta*Qty
			Trp_Strct.Pierre -= Qty
			Trp_Strct.Blé += Qty_got*0.79
			pr = "Échange effectué (avec un taux de change de $(round(beta*10000)/100)% et une taxe de 21%). Les $Trp ont donc échangé $Qty unités de $Ress1 contre $(Qty_got*0.79) unités de $Ress2. "
		elseif lowercase(Ress2) == "bois"
			#alpha = Bois_Start/Pir_Start #ce qu'elle reçoit/ce qu'elle donne
			beta = Bois_Disc_frac/Pir_Disc_frac
			#Taux = alpha*beta
			Qty_got = beta*Qty
			Trp_Strct.Pierre -= Qty
			Trp_Strct.Bois += Qty_got*0.79
			pr = "Échange effectué (avec un taux de change de $(round(beta*10000)/100)% et une taxe de 21%). Les $Trp ont donc échangé $Qty unités de $Ress1 contre $(Qty_got*0.79) unités de $Ress2. "
		elseif lowercase(Ress2) == "minerais"
			#alpha = Min_Start/Pir_Start #ce qu'elle reçoit/ce qu'elle donne
			beta = Min_Disc_frac/Pir_Disc_frac
			#Taux = alpha*beta
			Qty_got = beta*Qty
			Trp_Strct.Pierre -= Qty
			Trp_Strct.Minerais += Qty_got*0.79
			pr = "Échange effectué (avec un taux de change de $(round(beta*10000)/100)% et une taxe de 21%). Les $Trp ont donc échangé $Qty unités de $Ress1 contre $(Qty_got*0.79) unités de $Ress2. "
		end
	elseif lowercase(Ress1) == "minerais" && Trp_Strct.Minerais ≥ Qty
		if lowercase(Ress2) == "blé" 
			#alpha = Blé_Start/Min_Start #ce qu'elle reçoit/ce qu'elle donne
			beta = Blé_Disc_frac/Min_Disc_frac
			#Taux = alpha*beta
			Qty_got = beta*Qty
			Trp_Strct.Minerais -= Qty
			Trp_Strct.Blé += Qty_got*0.79
			pr = "Échange effectué (avec un taux de change de $(round(beta*10000)/100)% et une taxe de 21%). Les $Trp ont donc échangé $Qty unités de $Ress1 contre $(Qty_got*0.79) unités de $Ress2. "
		elseif lowercase(Ress2) == "bois"
			#alpha = Bois_Start/Min_Start #ce qu'elle reçoit/ce qu'elle donne
			beta = Bois_Disc_frac/Min_Disc_frac
			#Taux = alpha*beta
			Qty_got = beta*Qty
			Trp_Strct.Minerais -= Qty
			Trp_Strct.Bois += Qty_got*0.79
			pr = "Échange effectué (avec un taux de change de $(round(beta*10000)/100)% et une taxe de 21%). Les $Trp ont donc échangé $Qty unités de $Ress1 contre $(Qty_got*0.79) unités de $Ress2. "
		elseif lowercase(Ress2) == "pierre"
			#alpha = Pir_Start/Min_Start #ce qu'elle reçoit/ce qu'elle donne
			beta = Pir_Disc_frac/Min_Disc_frac
			#Taux = alpha*beta
			Qty_got = beta*Qty
			Trp_Strct.Minerais -= Qty
			Trp_Strct.Pierre += Qty_got*0.79
			pr = "Échange effectué (avec un taux de change de $(round(beta*10000)/100)% et une taxe de 21%). Les $Trp ont donc échangé $Qty unités de $Ress1 contre $(Qty_got*0.79) unités de $Ress2. "
		end
	else
		pr = "Échange impossible : vous n'avez pas assez de ressources"
	end
	return pr
end

# ╔═╡ 5aef7700-82be-4c8d-9837-f6ffce9f0dbb
"""
		Allocate_Ressources(World_Matrix, Actors_Matrix, Trp::String, Ressource::String, Qty)
	Cette fonction permemt d'allouer (donner) des ressources aux troupes. Elle prend 5 arguments: 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le vecteur qui contient tous les joueurs ;
	- La troupe concernée par le don ;
	- La ressource qui doit être donnée ;
	- La quantité de cette ressource à donner.
	Elle ne retourne rien mais effectue les modifications nécessaires dans le jeu.
	"""
function Allocate_Ressources(World_Matrix, Actors_Matrix, Trp::String, Ressource::String, Qty)
	Trp_Strct = Find_Troup(Trp,Actors_Matrix)
	if lowercase(Ressource) == "blé"
		Trp_Strct.Blé += Qty
	elseif lowercase(Ressource) == "bois"
		Trp_Strct.Bois += Qty
	elseif lowercase(Ressource) == "pierre"
		Trp_Strct.Pierre += Qty
	elseif lowercase(Ressource) == "minerais"
		Trp_Strct.Minerais += Qty
	elseif lowercase(Ressource) == "sel"
		Trp_Strct.Sel += Qty
	end
end

# ╔═╡ 171d8915-ec10-4afe-9705-6b10f0332213
"""
		Add_Interests(Actors_Matrix,rate)

	Cette fonction permet d'ajouter et informer sur la quantité de sel gangée par une troupe grâce aux taux d'intérêts ficés par le Roi. Elle prend 2 arguements : 
	- Le vecteur qui contient tous les joueurs ;
	- Le taux d'intérêt **DONNÉ EN DÉCIMALES** (e.g. 1.08 ou 1.12)
	Elle effectue les modifications nécessaires dans le jeu et informe sur la quantité de sel possédée par la troupe. 
	"""
function Add_Interests(Actors_Matrix,rate)
	Mat = []
	for element in Actors_Matrix[1:end-1]
		Old_Salt = element.Sel
		Trp = element.Nom
		element.Sel = rate*element.Sel
		Diff = element.Sel-Old_Salt
		push!(Mat,(Trp,Diff))
	end
	prs = []
	for i in 1:10
		pr = "$(Mat[i][1]) : $(round(100*Mat[i][2])/100) grammes de sel"
		push!(prs,pr)
	end
	ppr = "Résumé des apports des placements en sel (le taux d'intérêt fixé par le roi était de $(round(rate*100))%) :\n\n$(prs[1])\n$(prs[2])\n$(prs[3])\n$(prs[4])\n$(prs[5])\n$(prs[6])\n$(prs[7])\n$(prs[8])\n$(prs[9])\n$(prs[10])\n"
	return ppr
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
		    ("iscoast", Structure.IsCoast)
		])
		Info = Dico[f_field]
		push!(Data,Info)
	end
	DDIICCTT = Dict()
	for i in 1:length(Prp)
		line = Prp[i] => Data[i]
		push!(DDIICCTT,line)
	end
	#dictionnaire_trie = sort(collect(DDIICCTT), by = x -> x[1])
	return DDIICCTT
end

# ╔═╡ 02353a04-545f-4e79-b5b3-b93b441138ff
"""
		Show_Bourse_Info(World_Matrix)
	Cette fonction sert à extraire les informations nécessaires sur la bourse pour l'affichage et l'écriture du document récapitulatif. Elle prend un seul argument : 
	- Le vecteur qui contient tous les territoires composant le monde.

	Elle retourne un vecteur de 4 `strings`, qui donnent ce qu'on obtiendrait de chause ressource si on l'échangeait contre 100 unités de blé.   
	"""
function Show_Bourse_Info(World_Matrix)
	Min_Disc_frac,Blé_Disc_frac,Bois_Disc_frac,Pir_Disc_frac = Give_Market_State(World_Matrix)
	Bois_Start = Start_Ressources[1]
	Pir_Start = Start_Ressources[2]
	Blé_Start = Start_Ressources[3]
	Min_Start = Start_Ressources[4]
	Qty = 100.00
			
	#alpha_bois = Bois_Start/Blé_Start #ce qu'elle reçoit/ce qu'elle donne
	beta_bois = Bois_Disc_frac/Blé_Disc_frac
	#Taux_bois = alpha_bois*beta_bois
	Qty_got_bois = round(beta_bois*Qty*100)/100

	#alpha_pierre = Pir_Start/Blé_Start #ce qu'elle reçoit/ce qu'elle donne
	beta_pierre = Pir_Disc_frac/Blé_Disc_frac
	#Taux_pierre = alpha_pierre*beta_pierre
	Qty_got_pierre = round(beta_pierre*Qty*100)/100

	#alpha_minerais = Min_Start/Blé_Start #ce qu'elle reçoit/ce qu'elle donne
	beta_minerais = Min_Disc_frac/Blé_Disc_frac
	#Taux_minerais = alpha_minerais*beta_minerais
	Qty_got_minerais = round(beta_minerais*Qty*100)/100

	pr1 = "Blé : 100"
	pr2 = "Bois : $Qty_got_bois"
	pr3 = "Pierre : $Qty_got_pierre"
	pr4 = "Minerais : $Qty_got_minerais"

	return [pr1,pr2,pr3,pr4]
end

# ╔═╡ 0610f156-775c-4f71-8d28-c284770dabf2
"""
		Show_Salt_Info(Actors_Matrix)
	Cette fonction affiche et enregistre localement un graphe qui représente le classement général du jeu permanent. Elle prend un seul argument : 
	- Le vecteur qui contient tous les territoires composant le monde.
	Elle retourne une image de la situation qu'lle montre dans le notebook et qu'elle enregistre dans l'ordinateur dans le dossier Word. L'image peut donc être imprimée à chaque tour et être jointe aux dossiers
	"""
function Show_Salt_Info(Actors_Matrix)
    Salt_Dict = Dict()
    Surnames_Dict = Dict("Archers" => "ARCH", "Chevaliers" => "CHEUX", "Gueux" => "GUEUX", "Hardis" => "HARD", "Lanciers" => "LANC", "Paladins" => "PALAS", "Preux" => "PREUX", "Servants" => "SERVS", "Templiers" => "TEMPL", "Vaillants" => "VAICH")
    
    Colors_Dict = Dict("ARCH" => :deeppink4, "CHEUX" => :red, "GUEUX" => :midnightblue, "HARD" => :grey, "LANC" => :tan4, "PALAS" => :goldenrod1, "PREUX" => :black, "SERVS" => :darkgreen, "TEMPL" => :white, "VAICH" => :dodgerblue3)

    for element in Actors_Matrix[1:end-1]
        Salt_Dict[Surnames_Dict[element.Nom]] = element.Sel
    end

    k = collect(keys(Salt_Dict))
    v = collect(values(Salt_Dict))

    sorted_indices = sortperm(v, rev=true)
    k_sorted = k[sorted_indices]
    v_sorted = v[sorted_indices]

    bar_colors = [Colors_Dict[surname] for surname in k_sorted]

    title_font = font("Arial", 18)
    label_font = font("Arial", 14)
    tick_font = font("Arial", 8)

    grph = bar(k_sorted, v_sorted, xlabel="Troupes", ylabel="Quantité de sel [g]", title="Classement général jeu permanent", color=bar_colors, legend=false, titlefont=title_font, guidefont=label_font, tickfont=tick_font)

    savefig("./Words/Salt_Info.png")
	return grph
end


# ╔═╡ f5019805-05db-4c60-b87b-de6f39ac5556
md"""
### 7. Fonctions de sauvegarde
"""

# ╔═╡ 166ba06c-8fda-44a1-8d83-2c8bd90e3433
"""
			Save_Trp_Info(World_Matrix,Actors_Matrix,Trp::String)
	Cette fonction sert à sauvegarder les informations d'une troupe après un tour. Elle prend 3 arguments :  
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le vecteur qui contient tous les joueurs ;
	- Le nom de la troupe dont on souhaite traiter les informations ; 
	Elle crée un fichier `.txt` qu'elle stocke dans le dossier `Messages` du dossier du `Jeu Permanent` sur l'ordinateur. Attention : l'utilisateur du code doit donc avoir créé un tel dossier sur son ordinateur (ou modifier le chemin à sa guise pour que ça fonctionne comme il le souhaite). 
		"""
function Save_Trp_Info(World_Matrix,Actors_Matrix,Trp::String)
	TRP = uppercase(Trp)
	Trp_Strct = Find_Troup(Trp,Actors_Matrix)
	Prp = Properties(World_Matrix,Trp)
	LonesInfo = Update_LonesSituation(World_Matrix,Actors_Matrix,"NoPrint")
	Market_Info = Show_Bourse_Info(World_Matrix)
	date_du_jour = Dates.today()
	date_formattee = Dates.format(date_du_jour, "dd-mm-yyyy")
	#WRITING FILE
	chem = "./Messages/Situation_$Trp.txt"
	fichier = open(chem,"w")
	write(fichier,"JEU PERMANENT GCU 2024\nFICHE RÉCAPITULATIVE - $TRP\nMise à jour du $date_formattee","\n\n")
	#Gen info
	write(fichier,"1. INFORMATIONS GENERALES :\n\n")
	write(fichier, "Territoires possédés :\n")
	write(fichier,"- Nombre : $(Trp_Strct.Territoires)\n- Numéros d'identité : $(Prp[:])\n\n")
	write(fichier,"Armée :\n- Nombre de soldats : $(Trp_Strct.Soldats)\n- Nombre de bateaux : $(Trp_Strct.Bateaux)\n\n")
	write(fichier,"Ressources :\n- Minerais : $(Trp_Strct.Minerais)\n- Blé : $(Trp_Strct.Blé)\n- Bois : $(Trp_Strct.Bois)\n- Pierre : $(Trp_Strct.Pierre)\n\n")


	write(fichier,"État du marché (valeurs de conversion de 100 unités de blé) :\n")
	for element in Market_Info
		write(fichier,element,"\n")
	end
	write(fichier,"\n")
	
	#Terr info
	write(fichier,"2. DETAILS DES TERRITOIRES : \n\n")
	for element in Prp
		IF = Terr_Info(World_Matrix,element)
		for element in IF
			write(fichier,element,"\n")
		end
		write(fichier,"\n")
	end

	#Info sur les rentes de sel
	write(fichier,"3. INFORMATTIONS SUR RÉCOLTES DE SEL DEPUIS LE DERNIER TOUR : \n\n")
	Salt_Info = []
	for Trp in Actors_Matrix
		Prop = Properties(World_Matrix,Trp.Nom)
		Sizes = 0
		for i = 1:size(Prop)[1]
			CaseID = Prop[i]
			Terr = World_Matrix[CaseID]
			Sizes += Terr.Type
			if Terr.IsCoast == true 
				Sizes += 0.7
			end
			if Terr.IsFluvial == true
				Sizes += 0.3
			end
			Sizes = round(Sizes)
		end
		ppr = "$(Trp.Nom) : $(2*Sizes) grammes de sel"
		push!(Salt_Info, ppr)
	end
	write(fichier, "Les récoltes ont été bonnes ! Voici les quantités de sels récoltées par chaque troupes depuis le dernier tour grâce aux rentes des territoires. Rappel : le but du jeu est d'avoir le plus de sel possible ! Ce dernier s'obtient en gagnant plus de territoires, en investissant dans le sel, en remportant les épreuves démographiques, ou encore en excellant dans d'autres épreuves du camp !\n\n$(Salt_Info[1])\n$(Salt_Info[2])\n$(Salt_Info[3])\n$(Salt_Info[4])\n$(Salt_Info[5])\n$(Salt_Info[6])\n$(Salt_Info[7])\n$(Salt_Info[8])\n$(Salt_Info[9])\n$(Salt_Info[10])\n\n")
	
	#Info autres troupes
	write(fichier,"4. INFORMATTIONS SUR LES AUTRES TROUPES : \n\n")
	for element in LonesInfo
		write(fichier,"$(uppercase(element.Nom)) :\n")
		write(fichier,"Nombre de territoires : $(element.Territoires)\n")
		write(fichier,"Nombre de soldats : $(element.Soldats)\n")
		write(fichier,"Nombre de bateaux : $(element.Bateaux)\n")
		write(fichier,"Quantité de minerais : $(element.Minerais)\n")
		write(fichier,"Quantité de blé : $(element.Blé)\n")
		write(fichier,"Quantité de bois : $(element.Bois)\n")
		write(fichier,"Quantité de Pierre : $(element.Pierre)\n")
		write(fichier,"\n")
	end
	close(fichier)
end

# ╔═╡ 470479de-fd0c-4a93-826b-82665a9ede0b
"""
		Generate_All_txt(World_Matrix,Actors_Matrix)
	Cette fonction exécute la fonction `Save_Trp_Info(World_Matrix,Actors_Matrix,Trp)` pour chacune des troupes, de sorte à stocker tous les fichiers `.txt` nécessaires. Elle prend deux arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le vecteur qui contient tous les joueurs.
	Notez qu'un code python `Word_generator.py` a aussi été créé pour convertir les fichiers `.txt` en `.docx`, afin de faciliter la lecture des scouts. Ce code doit être indépendemment de ce notebook. Il est disponible sur `Github`.
	"""
function Generate_All_txt(World_Matrix,Actors_Matrix)
	for element in Troupe_Names
		Save_Trp_Info(World_Matrix,Actors_Matrix,element)
	end
end

# ╔═╡ 40c0eae6-51cb-4c34-bc50-d4d1de2b1086
"""
		Save_Game(World_Matrix::Vector{Any})
	Cette fonction sert à sauvegarder l'état actuel du jeu. Elle prend un argument :
	- Le vecteur qui contient tous les territoires composant le monde
	- Le vecteur qui contient tous les joueurs.
	Elle retourne un message de confirmation et génère deux fichiers `.txt` qui contiennent la sauvegarde du jeu. Ces fichiers peuevnt éventuellement être échangés par des chefs du SDT entre eux pour pouvoir relancer le jeu depuis différents ordinateurs, ou envoyés à Cerato pour qu'il puisse suivre l'état du jeu à distance ;-).
	"""
function Save_Game(World_Matrix::Vector{Any}, Actors_Matrix)
	Update_LonesSituation(World_Matrix, Actors_Matrix, "NoPrint")
    date_du_jour = Dates.today()
    chem_Terr = "./Sauvegardes/Sauvegarde_Terr_$date_du_jour.txt"
	chem_Trps = "./Sauvegardes/Sauvegarde_Trps_$date_du_jour.txt"
    open(chem_Terr, "w") do fichier
        for element in World_Matrix
            @printf(fichier, "%-10d %-10d %-10s %-10.2f %-10.2f %-10.2f %-10.2f %-10.2f %-10.2f %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n",
                element.CaseID, element.Type, element.Troupe, element.Soldats, element.Bateaux, element.Minerais,
                element.Blé, element.Bois, element.Pierre, element.Ferme, element.Scierie, element.Carrière,
                element.Mine, element.Port, element.IsFluvial, element.IsCoast)
        end
    end

	open(chem_Trps, "w") do fichier
        for element in Actors_Matrix
            @printf(fichier, "%-10s %-10d %-10d %-10.2d %-10.2f %-10.2f %-10.2f %-10.2f %-10.2f\n",
                element.Nom, element.Territoires, element.Soldats, element.Bateaux, element.Minerais, element.Blé, element.Bois, element.Pierre, element.Sel)
        end
    end
	
end

# ╔═╡ eafbff43-6241-42b2-a27f-1f2d68ed6415
"""
		Load_Game(file_path::String)
	Cette fonction sert à uploader une sauvegarde du jeu. Elle prend un argument : 
	- Le chemin vers le fichier de sauvegarde (généré préalablement par la fonction `Save_Game`).
	Elle ne retourne rien, met permet de redémarrer le jeu depuis une suavegarde antérieure suite à un crash du programme ou si un changement d'ordinateurs est nécessaire de tours en tours.

	**ATTENTION :** Cette fonction s'utilise au tout début de l'interface, dans une cellule de code cachée par défaut. Pour récupérer une suavegarde, il faut donc : 
	1. Ouvrir la la première cellule (cachée par défaut) de la partie "PARTIE B - INTERFACE DE JEU"
	2. Mettre cette cellule dans l'état suivant : 
		begin
			#Run the following if you want to restart the game
			#World,Troupes = Start_Game()
		
			#Run the following command if you want to simulate a mid-game situation
			#World,Troupes = Temporary_WorldFiller(World,Troupes)
			
			#Run the following if you want to recover abackup version of the game (adapt the name !)
			World, Troupes = Load_Game("./Sauvegardes/Sauvegarde_2024-06-17.txt")
			
			md"Pour **récupérer une sauvegarde** ou **commencer une nouvelle partie**, veuillez modifier cette cellule. N'oubliez pas de sauvegarder la partie à la fin de chaque tour !"
		end
	En veillant bien sûr à adapter le nom du fichoer txt à la version du jeu qu'on souhaite uploader ! N'oubliez pas également de recacher la cellule par après, pour éviter de la refaire tourner par erreur ! (en la faisant retourner par erreur, la partie sera réinitialisée à l'état de la sauvegarde mentionnée, donc tous les changements effectués depuis lors seront perdus !)
	"""
function Load_Game(file_path_Terr::String, file_path_Trps::String)
    World_Matrix = Vector{Any}()
	Actors_Matrix = Vector{Any}()
    open(file_path_Terr, "r") do fichier
        for line in eachline(fichier)
            fields = split(line)
            territoire = Territoire(
                parse(Int, fields[1]),
                parse(Int, fields[2]),
                fields[3],
                parse(Float64, fields[4]),
                parse(Float64, fields[5]),
                parse(Float64, fields[6]),
                parse(Float64, fields[7]),
                parse(Float64, fields[8]),
                parse(Float64, fields[9]),
                parse(Bool, fields[10]),
                parse(Bool, fields[11]),
                parse(Bool, fields[12]),
                parse(Bool, fields[13]),
                parse(Bool, fields[14]),
                parse(Bool, fields[15]),
                parse(Bool, fields[16])
            )
            push!(World_Matrix, territoire)
        end
    end

	open(file_path_Trps, "r") do fichier
        for line in eachline(fichier)
            fields = split(line)
            troupe = Troupe(
                fields[1],
                parse(Int, fields[2]),
                parse(Int, fields[3]),
				parse(Int, fields[4]),
                parse(Float64, fields[5]),
                parse(Float64, fields[6]),
                parse(Float64, fields[7]),
                parse(Float64, fields[8]),
                parse(Float64, fields[9]),
            )
            push!(Actors_Matrix, troupe)
        end
    end
	#_, Actors_Matrix = Start_Game()
	Update_LonesSituation(World_Matrix,Actors_Matrix,"Noprint")
    return World_Matrix, Actors_Matrix
end

# ╔═╡ 2e77c3fc-94bd-4dfe-a8b9-4302db6b85fb
md"### 8. Fonctions \"`Execute()`\""

# ╔═╡ 018f1d80-9fbc-4d36-a41e-319c86511b76
md"## PARTIE B - INTERFACE DE JEU"

# ╔═╡ ce6b11f9-8230-4076-8135-12df833d4a82
begin
	#Run the following if you want to restart the game
	#World,Troupes = Start_Game()

	#Run the following command if you want to simulate a mid-game situation
	#World,Troupes = Temporary_WorldFiller(World,Troupes)
	
	#Run the following if you want to recover abackup version of the game (adapt the name !)
	World, Troupes = Load_Game("./Sauvegardes/Sauvegarde_Terr_2024-07-17.txt","./Sauvegardes/Sauvegarde_Trps_2024-07-17.txt")
	
	md"Pour **récupérer une sauvegarde** ou **commencer une nouvelle partie**, veuillez modifier cette cellule. N'oubliez pas de sauvegarder la partie à la fin de chaque tour !"
end

# ╔═╡ 2811036d-a050-4b7b-8d9e-5d6a67aacc38
"""
		Apply_catastrophee(World_Matrix,Actors_Matrix,Cat_Type)
	Cette fonction sert à appliquer une catstrophe sur le monde. Elle prend 3 arguments : 
	- Le vecteur qui contient tous les territoires composant le monde ;
	- Le vecteur qui contient tous les joueurs ;
	- Le nom de la castrophe qui doit être appliquée.
	Elle retourne, par facilité, les identités des territoires touchés. Elle effectue toutes les modifications nécessaires dans le jeu et génère les fichiers .txt nécessaires pour le rapport. Ce rapport peut par la suite être obtenu en exécutant dans l'ordre les fonctions `Catastrophee_reporter.py` et `Catastrophee_report_docx.py`
	"""
function Apply_catastrophee(World_Matrix,Actors_Matrix,Cat_Type)
	#Sauver l'état initial dans l'ordinateur
	for element in Actors_Matrix[1:10]
		chem = "./Catastrophes/Sit_Pro_Cata_$(element.Nom).txt"
		fichier = open(chem,"w")
		write(fichier,"$(element.Territoires)\n")
		write(fichier,"$(element.Soldats)\n")
		write(fichier,"$(element.Bateaux)\n")
		write(fichier,"$(element.Minerais)\n")
		write(fichier,"$(element.Blé)\n")
		write(fichier,"$(element.Bois)\n")
		write(fichier,"$(element.Pierre)\n")
		close(fichier)
	end
	if lowercase(Cat_Type) == "tropical rains"
		Impacted_Terrs = Select_Catastrophee_Terr(World_Matrix,20)
		for element in World_Matrix
			if element.CaseID in Impacted_Terrs && element.Troupe ≠ "Autochtones" && element.Type ≠ 0
				Trp = element.Troupe
				Trp_Strct = Find_Troup(Trp,Actors_Matrix)
				if element.IsFluvial == true
					element.Port = false
					element.Bateaux = 0
					if element.Soldats > 10
						element.Soldats -= 2
					elseif element.Soldats > 5
						element.Soldats -=1
					end
					Trp_Strct.Blé -= 2*element.Blé
					Trp_Strct.Bois -= element.Bois/2
				else
					Trp_Strct.Blé -= element.Blé
				end
				if element.Soldats == 0
				 element.Troupe = "Autochtones"
				 element.Soldats = round(3*rand(1)[1])+1
			 	end
			end
		end
		Mess = "Chers Lones, \n Votre souverain vous adresse des nouvelles bien sombres. Ce matin, un émissaire est arrivé à la capitale pour me rapporter des pluies torrentielles qui se sont abattues sur certaines de nos provinces. Les champs de blé ont été dévastés à de nombreux endroits, et la situation est encore plus critique pour les territoires riverains : des crues dévastatrices ont emporté une grande partie des cultures et ont rendu bon nombre de nos forêts impraticables. Ces inondations ont été si violentes par moments que plusieurs soldats ont perdu la vie en tentant de protéger leurs biens et leurs proches. Mon émissaire a rédigé un rapport détaillant les pertes que vous avez subies, et que vous trouverez ci-dessous. Dans cette période critique, j'ai décidé de vous convoquer tous à la Capitale aujourd'hui à 15h00 pour discuter des mesures à prendre afin de rétablir nos conquêtes malgré ces épreuves. Je vous encourage à vous réunir avec vos conseillers internes pour préparer vos stratégies à l'avance, car le temps presse. Quoi qu'il advienne, soyez prêts... \n\nTerritoires touchés : $(Impacted_Terrs)"
	elseif lowercase(Cat_Type) == "forest fires"
		Impacted_Terrs = Select_Catastrophee_Terr(World_Matrix,10)
		 for element in World_Matrix
			 if element.CaseID in Impacted_Terrs && element.Troupe ≠ "Autochtones" && element.Type ≠ 0
			 	Trp = element.Troupe
				Trp_Strct = Find_Troup(Trp,Actors_Matrix)
				element.Ferme = false
				element.Scierie = false
				Trp_Strct.Blé -= 2*element.Blé
				Trp_Strct.Bois -= 3*element.Blé
				if element.Soldats > 10
					element.Soldats -= 4
				elseif element.Soldats > 5
					element.Soldats -= 2
				elseif element.Soldats > 0
					element.Soldats -= 1
				end
				 if element.Soldats == 0
					 element.Troupe = "Autochtones"
					 element.Soldats = round(3*rand(1)[1])+1
				 end
			 end
		 end
		Mess = "Chers Lones, \n Votre Roi vous adresse des nouvelles particulièrement douloureuses. Ce matin, un messager est arrivé à la capitale pour me rapporter des événements tragiques. Des incendies de forêt dévastateurs ont ravagé certains territoires de nos provinces durant la nuit. Les champs de blé et les forêts ont été sévèrement touchés, causant d'importantes pertes. Les flammes ont également englouti les fermes et les scieries des régions touchées, entraînant la perte de nombreux soldats pris au piège. Mon émissaire a dressé un rapport détaillé des pertes que vous avez subies, que vous trouverez ci-dessous. Face à cette situation critique, j'ai pris la décision de vous convoquer tous à la Capitale aujourd'hui à 15h00 afin de discuter des mesures à prendre pour surmonter ces épreuves et restaurer nos conquêtes. Je vous encourage vivement à vous réunir avec vos conseillers internes pour élaborer vos stratégies à l'avance, car chaque instant compte. Quoi qu'il advienne, soyez prêts...\n\nTerritoires touchés :\n$(Impacted_Terrs)"
	elseif lowercase(Cat_Type) == "earthquakes"
		Impacted_Terrs = Select_Catastrophee_Terr(World_Matrix,10)
		 for element in World_Matrix
			 if element.CaseID in Impacted_Terrs && element.Troupe ≠ "Autochtones" && element.Type ≠ 0
			 	Trp = element.Troupe
				Trp_Strct = Find_Troup(Trp,Actors_Matrix)
				element.Carrière = false
				element.Mine = false
				Trp_Strct.Minerais -= 3*element.Minerais
				Trp_Strct.Pierre -= 2*element.Pierre
				if element.Soldats > 10
					element.Soldats -= 3
				elseif element.Soldats > 5
					element.Soldats -= 2
				elseif element.Soldats > 0
					element.Soldats -= 1
				end
			 end
			 if element.Soldats == 0
				 element.Troupe = "Autochtones"
				 element.Soldats = round(3*rand(1)[1])+1
			 end
		 end
		Mess = "Chers Lones,\nC'est avec une profonde angoisse que je vous adresse une fois de plus la parole aujourd'hui. Malheureusement, nos terres ont été secouées par des forces incontrôlables. Ce matin, les nouvelles sont arrivées à la capitale, annonçant des tremblements de terre dévastateurs. Les mines et les carrières à travers les territoires touchés sont désormais en ruines, nous laissant calculer le coût en pierres précieuses et en minerais. De plus, nous sommes attristés par la perte de nos soldats qui, dans leurs heures de loisir, travaillaient dans les sous-terrains et ont péri dans les décombres. Dans le sillage de cette tragédie, je vous appelle tous à vous rassembler à la Capitale à 15h00 aujourd'hui. Ensemble, nous devons tracer une voie à suivre dans ces moments troublés. Je vous encourage à nouveau à vous réunir avec vos conseillers internes pour élaborer vos stratégies à l'avance, car nous n'avons pas de temps à perdre. Quels que soient les défis à venir, soyons prêts à y faire face...\n\nTerritoires touchés :\n$(Impacted_Terrs)"
	elseif lowercase(Cat_Type) == "tsunami"
		Impacted_Terrs = Select_Catastrophee_Terr(World_Matrix,20)
		 for element in World_Matrix
			 if element.CaseID in Impacted_Terrs && element.Troupe ≠ "Autochtones" && (element.IsCoast == true || element.IsFluvial == true) && element.Type ≠ 0
			 	Trp = element.Troupe
				Trp_Strct = Find_Troup(Trp,Actors_Matrix)
				element.Ferme = false
				element.Scierie = false
				element.Port = false
				element.Bateaux = 0
				Trp_Strct.Bois -= 3*element.Bois
				Trp_Strct.Blé -= 4*element.Blé
				if element.Soldats > 10
					element.Soldats -= 5
				elseif element.Soldats > 5
					element.Soldats -= 3
				elseif element.Soldats > 3
					element.Soldats -= 2
				elseif element.Soldats > 0
					element.Soldats -= 1
				end
			 end
			 if element.Soldats == 0
				 element.Troupe = "Autochtones"
				 element.Soldats = round(3*rand(1)[1])+1
			 end
		 end
		Mess = "Chers Lones,\nC'est avec une profonde angoisse que je vous adresse une fois de plus la parole. Malheureusement, nos terres ont été secouées par des forces incontrôlables. Ce matin, les nouvelles sont arrivées à la capitale, annonçant un tsunami dévastateur qui a ravagé nos côtes et nos campagnes. Les cultures de blé, qui nourrissaient nos familles et nos soldats, ont été entièrement ravagées. Les vagues impitoyables ont déraciné les plants et emporté les récoltes, nous laissant avec une pénurie alimentaire à laquelle nous devons faire face de toute urgence.Les bâtiments fragiles, tels que les fermes, les scieries et les ports, ont été complètement détruits. Les fermes, qui étaient le cœur de notre production agricole, ne sont plus que des ruines boueuses. Les scieries, vitales pour notre approvisionnement en bois, ont été emportées par les flots tumultueux. Les ports, qui étaient nos portes ouvertes vers le commerce et l’approvisionnement, sont désormais impraticables, les quais ayant été réduits à des débris flottants. Ce qui est encore plus déchirant, c’est la perte de nos braves soldats. Beaucoup ont péri dans cette catastrophe, surpris par les eaux déchaînées alors qu'ils tentaient de sécuriser les villages et d'aider à l'évacuation des habitants. Leur sacrifice ne sera pas oublié, et leur bravoure doit nous inspirer dans les jours sombres à venir. Dans le sillage de cette tragédie, je vous appelle tous à vous rassembler à la Capitale à 15h00 aujourd'hui. Ensemble, nous devons tracer une voie à suivre dans ces moments troublés. Je vous encourage à nouveau à vous réunir avec vos conseillers internes pour élaborer vos stratégies à l'avance, car nous n'avons pas de temps à perdre.Quoi qu'il advienne, soyez prêts...\n\nTerritoires touchés :\n$(Impacted_Terrs)"
	elseif lowercase(Cat_Type) == "virus"
		Impacted_Terrs = Select_Catastrophee_Terr(World_Matrix,15)
		 for element in World_Matrix
			 if element.CaseID in Impacted_Terrs && element.Troupe ≠ "Autochtones" && element.Type ≠ 0
			 	Trp = element.Troupe
				Trp_Strct = Find_Troup(Trp,Actors_Matrix)
				element.Ferme = false
				Trp_Strct.Blé -= 5*element.Blé
				if element.Soldats > 10
					element.Soldats -= 6
				elseif element.Soldats > 5
					element.Soldats -= 3
				elseif element.Soldats > 3
					element.Soldats -= 2
				elseif element.Soldats > 0
					element.Soldats -= 1
				end
			 end
			 if element.Soldats == 0
				 element.Troupe = "Autochtones"
				 element.Soldats = round(3*rand(1)[1])+1
			 end
		 end
		Mess = "C'est avec une profonde angoisse que je vous adresse cette lettre. Malheureusement, nos terres ont été frappées par un mal invisible mais dévastateur. Ce matin, les nouvelles sont arrivées à la capitale, annonçant que le virus qui sévit depuis des semaines a causé des ravages considérables. La population a été durement touchée, et nos soldats n'ont pas été épargnés. Beaucoup ont péri ou ont dû quitter l'armée en raison de leur maladie. Leur absence se fait cruellement sentir, non seulement dans nos rangs militaires, mais aussi dans nos cœurs. Le marché du blé a également énormément souffert. Nombreuses sont les cultures qui ont été contaminées, rendant les récoltes inutilisables. Certaines fermes et champs ont dû être brûlés par précaution, dans une tentative désespérée de stopper la propagation du virus. Cette situation nous laisse face à une crise alimentaire sans précédent, nécessitant des mesures urgentes et concertées. Dans le sillage de cette tragédie, je vous appelle tous à vous rassembler à la Capitale à 15h00 aujourd'hui. Ensemble, nous devons tracer une voie à suivre dans ces moments troublés. Je vous encourage à nouveau à vous réunir avec vos conseillers internes pour élaborer vos stratégies à l'avance, car nous n'avons pas de temps à perdre. Soyez prêts...\n\nTerritoires touchés :\n$(Impacted_Terrs)"
	elseif lowercase(Cat_Type) == "tornado"
		Impacted_Terrs = Select_Catastrophee_Terr(World_Matrix,12)
		 for element in World_Matrix
			 if element.CaseID in Impacted_Terrs && element.Troupe ≠ "Autochtones" && element.Type ≠ 0
			 	Trp = element.Troupe
				Trp_Strct = Find_Troup(Trp,Actors_Matrix)
				element.Ferme = false
				element.Scierie = false
				if element.Bateaux > 0
					element.Bateaux -= 1
				end
				Trp_Strct.Blé -= 3*element.Blé
				Trp_Strct.Bois -= 2*element.Bois
				if element.Soldats > 10
					element.Soldats -= 4
				elseif element.Soldats > 5
					element.Soldats -= 2
				elseif element.Soldats > 0
					element.Soldats -= 1
				end
			 end
			 if element.Soldats == 0
				 element.Troupe = "Autochtones"
				 element.Soldats = round(3*rand(1)[1])+1
			 end
		 end
		Mess = "C'est avec une profonde angoisse que je vous adresse une fois de plus la parole aujourd'hui. Malheureusement, nos terres ont été frappées par des forces incontrôlables. Ce matin, les nouvelles sont arrivées à la capitale, annonçant que des tornades dévastatrices ont ravagé notre territoire. Les champs de blé et les forêts ont été sévèrement touchés. Les récoltes, qui nourrissaient nos populations et nos armées, ont été emportées par les vents violents. Nos forêts, sources de bois et de vie, ne sont plus que des amas de troncs déracinés et de branches brisées. Les fermes et les scieries, si fragiles face à ces colères de la nature, ont été réduites en ruines. Nos moyens de production agricole et forestière sont désormais gravement compromis. Nos soldats, courageux et dévoués, ont payé un lourd tribut en tentant de protéger leurs biens et leurs familles. Certains ont péri, d'autres ont été grièvement blessés. Ces pertes dans nos rangs affaiblissent notre capacité à défendre et à reconstruire nos territoires, et leur absence se fait cruellement sentir. De plus, certains de nos bateaux, essentiels pour le commerce et le ravitaillement, ont été détruits et sont maintenant inutilisables. Cette perte aggrave encore notre situation, rendant les échanges et les approvisionnements encore plus difficiles. Dans le sillage de cette tragédie, je vous appelle tous à vous rassembler à la Capitale à 15h00 aujourd'hui. Ensemble, nous devons tracer une voie à suivre dans ces moments troublés. Je vous encourage à nouveau à vous réunir avec vos conseillers internes pour élaborer vos stratégies à l'avance, car nous n'avons pas de temps à perdre. Soyez prêts...\n\nTerritoires touchés :\n$(Impacted_Terrs)"
	end
	# Eviter que les troupes passent en négatif niveau ressources
	for element in Actors_Matrix
		if element.Blé < 0
			element.Blé = 0
		end
		if element.Bois < 0
			element.Bois = 0
		end
		if element.Pierre < 0
			element.Pierre = 0
		end
		if element.Minerais < 0
			element.Minerais = 0
		end
	end
	# Sauver l'état Post-Cata
	Update_LonesSituation(World,Troupes,"NoPrint")
	for element in Actors_Matrix[1:10]
		chem = "./Catastrophes/Sit_Post_Cata_$(element.Nom).txt"
		fichier = open(chem,"w")
		write(fichier,"$(element.Territoires)\n")
		write(fichier,"$(element.Soldats)\n")
		write(fichier,"$(element.Bateaux)\n")
		write(fichier,"$(element.Minerais)\n")
		write(fichier,"$(element.Blé)\n")
		write(fichier,"$(element.Bois)\n")
		write(fichier,"$(element.Pierre)\n")
		close(fichier)
	end
	#Sauver le message du Roi
	date_du_jour = Dates.today()
	date_formattee = Dates.format(date_du_jour, "dd-mm-yyyy")
	chem = "./Catastrophes/King_Message.txt"
	fichier = open(chem,"w")
	write(fichier,"JEU PERMANENT GCU 2024\nCONVOCATION À LA CAPITALE\nEn date du $date_formattee, à 15h00","\n\n")
	write(fichier,"$Mess")
	close(fichier)
	return Impacted_Terrs
end

# ╔═╡ fc69d958-b5e0-45b8-bdcc-6ca858059fc0
function Execute_BourseInfo()
	try 
		info_vec = Show_Bourse_Info(World)
		with_terminal() do
			println("État du marché (valeurs de conversion de 100 unités de blé) :")
			println("-------------------------------------------------------------")
			for element in info_vec
				println(element)
			end
		end
	catch
		println("Veuillez remplir les cases puis cliquer sur envoyer pour confirmer votre transfert")
	end
end

# ╔═╡ a0406049-10c0-4b93-9f0e-ac7eebe6d979
md"""### AFFICHAGE
	Sélectionnez ici ce que vous souhaitez afficher :

	 $(@bind GenClass CheckBox()) Classement général\
	 $(@bind SitGen CheckBox()) Situation des troupes\
	 $(@bind PropTerr CheckBox()) Caractéristiques d'un territoire\
	 $(@bind PropTrp CheckBox()) Propriétés d'une troupe\
	 $(@bind Market CheckBox()) État du marché\
	"""

# ╔═╡ 400579f3-b212-4902-b96e-8659c33245da
if PropTerr == true
	md"""Numéro d'identité du territoire concerné : $@bind TInfo PlutoUI.confirm(html"<input type=text>")"""
elseif PropTrp == true
	sp = html"&nbsp"
	md""" **Cochez les informations que vous voulez voir apparaître** :\
	 $(@bind cad CheckBox()) CaseID $sp $sp $sp $sp $(@bind tye CheckBox()) Type $sp $sp $sp $sp $(@bind sdt CheckBox()) Soldats $sp $sp $sp $sp $(@bind bax CheckBox()) Bâteaux $sp $sp $sp $sp $(@bind mis CheckBox()) Minerais $sp $sp $sp $sp $(@bind ble CheckBox()) Blé $sp $sp $sp $sp $(@bind bos CheckBox()) Bois $sp $sp $sp $(@bind pie CheckBox()) Pierre $sp $sp $sp $sp $sp $(@bind fee CheckBox()) Ferme $sp $sp $sp $(@bind sce CheckBox()) Scierie $sp $sp $sp $sp $(@bind cae CheckBox()) Carrière $sp $sp $sp $sp $(@bind mie CheckBox()) Mine $sp $sp $sp $sp $sp $sp $sp $(@bind pot CheckBox()) Port $sp $sp $sp $(@bind fll CheckBox()) Fluvial $(@bind cor CheckBox()) Côtier
	
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
	button_labels = [cad, tye, sdt, bax, mis, ble, bos, pie, fee, sce, cae, mie, pot, fll, cor]
	button_names = ["CaseID", "Type", "Soldats", "Bateaux", "Minerais", "Blé", "Bois", "Pierre", "Ferme", "Scierie", "Carrière", "Mine", "Port", "IsFluvial", "IsCoast"]
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
	Row_header_info = collect(keys(API["Soldats"]))
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
elseif Market == true
	Execute_BourseInfo()
elseif GenClass == true
	Show_Salt_Info(Troupes)
end

# ╔═╡ 91a757ac-e56c-4228-8cff-fbd25fa27714
md"""### ACTIONS

Sélectionnez ici l'action que le joueur souhaite exécuter : 

 $(@bind Turn CheckBox()) Début d'un tour\
 $(@bind Transfer CheckBox()) Transférer les troupes d'un territoire vers un autre\
 $(@bind Buy CheckBox()) Acheter un bâtiment et le placer sur un de ses territoire\
 $(@bind Salt CheckBox()) Acheter du sel avec des ressources\
 $(@bind Ass CheckBox()) Attaquer un territoire\
 $(@bind Exc CheckBox()) Convertir des ressources\
 $(@bind EndTurn CheckBox()) Allocation de sel ou de ressources par le Roi (fin du tour)\
 $(@bind Intr CheckBox()) Allocation des intérêts sur le sel placé\
"""

# ╔═╡ 34d229fe-06af-4179-b44a-5c1208f86ff0
begin
	if Ass == true
	md"""### Assurez-vous de votre stratégie...
	Une fois ces cases remplies, impossible de faire marche arière : les caractéristiques du territoire que vous attaquez s'afficheront, pour que vous compreniez ce qui se passe, mais vous ne pourrez pas décider de batre en retraite !
	
	ID du territoire d'où part l'attaque : $(@bind AttStg html"<input type=text>")\
	ID du territoire attaqué : $(@bind DefStg html"<input type=text>")
	"""
	elseif Transfer == true
	md"""
	 $(@bind Multiple_Transfer CheckBox()) Transférer plusieurs troupes en une fois\
	"""
	elseif Buy == true
	md"""
	 $(@bind Buy_Mil CheckBox()) Acheter plusieurs unités militaires (soldats ou bateaux)\
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
	if Buy_Mil == false
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
	elseif Buy_Mil == true
		@bind Buy_Mil_Data PlutoUI.confirm(
			PlutoUI.combine() do Child
				@htl("""
				<h3>Achat d'unités militaires</h3>
				
				<ul>
				$([
					@htl("<li>$(name): $(Child(name, html"<input type=text>"))")
					for name in ["Troupe qui désire effectuer l'achat ", "Unité à acheter ","Quantité d'unités ","ID du territoire de destination "]
				])
				</ul>
				""")
			end
		)
	end
elseif Turn == true
	md"""Veuillez, par sécurité, écrire : "`Je confirme qu'un nouveau tour doit avoir lieu`" : $@bind Mess_Turn PlutoUI.confirm(html"<input type=text>")"""
elseif Transfer == true
	if Multiple_Transfer == false
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
	elseif Multiple_Transfer == true
		@bind Multiple_Transfer_Data PlutoUI.confirm(
			PlutoUI.combine() do Child
				@htl("""
				<h3>Transfert MULTIPLE de troupes</h3>
				<h6>Attention : veillez à séparer les éléments avec des virgules !</h6>
				<ul>
				
				$([
					@htl("<li>$(name): $(Child(name, html"<input type=text>"))")
					for name in ["Numéro du territoire de départ ", "Numéro des territoires de destination "]
				])
				</ul>
				""")
			end
		)
	end
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
			<h3>Lancez l'attaque !</h3>
			
			<ul>
			$([
				@htl("<li>$(name): $(Child(name, html"<input type=text>"))")
				for name in ["ID du territoire d'où part l'attaque ","ID du territoire attaqué"]
			])
			</ul>
			""")
		end
	)
elseif Exc == true
	@bind Exc_Data PlutoUI.confirm(
		PlutoUI.combine() do Child
			@htl("""
			<h3>Échange de ressources avec la trésorerie royale </h3>
			
			<ul>
			$([
				@htl("<li>$(name): $(Child(name, html"<input type=text>"))")
				for name in ["Troupe qui souhaite effectuer l'échange ","Type de ressource qu'on souhaite vendre ", "Quantité de cette ressource que l'on souhaite vendre ", "Type de ressource que l'on souhaite recevoir "]
			])
			</ul>
			""")
		end
	)
elseif EndTurn == true
	@bind King_Data PlutoUI.confirm(
		PlutoUI.combine() do Child
			@htl("""
			<h3>Allocation de ressources/sel par le Roi </h3>
			<h6>Attention : Remplissez tous les champs (inscrivez 0 aux troupes auxquelles il ne faut rien allouer) !</h6>
			<ul>
			$([
				@htl("<li>$(name): $(Child(name, html"<input type=text>"))")
				for name in ["Ressource ", "Archers ", "Chevaliers ", "Gueux ", "Hardis ", "Lanciers ", "Paladins ", "Preux ", "Servants ", "Templiers ", "Vaillants "]
			])
			</ul>
			""")
		end
	)
	
elseif Intr == true
	@bind Intr_Data PlutoUI.confirm(
		PlutoUI.combine() do Child
			@htl("""
			<h3>Réception des intérêts sur le sel placé </h3>
			<ul>
			$([
				@htl("$(name): $(Child(name, html"<input type=text>"))")
				for name in ["Taux d'intérêt (fixé par le Roi) "]
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

# ╔═╡ 8a577e66-9a7a-49e6-abbf-b0f615bab9ed
function Execute_Buy_Mil()
	try
		Trp = Buy_Mil_Data[1]
		Unit = Buy_Mil_Data[2]
		Qty = parse(Int64,Buy_Mil_Data[3])
		Terr = parse(Int64,Buy_Mil_Data[4])
		pr = Add_Mil_Entities(World, Troupes,Trp,Unit,Qty,Terr)
		println(pr)
	catch
		with_terminal() do
			println("Veuillez remplir les cases puis cliquer sur envoyer pour confirmer vos achats.")
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
			Apply_catastrophee(World,Troupes,rand(Catas))
			pr = New_Turn(World,Troupes)
			#pr = "Un nouveau tour a bien été effectué"
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
		pr = Ressource2Salt(World,Troupes,Trp,Ressource,Qty)
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

# ╔═╡ 662471db-b727-4371-9efd-0f2d5e03e4be
function Execute_Ressource_Exchange()
	try
		Trp = Exc_Data[1]
		Ress1 = Exc_Data[2]
		Qty = parse(Int64,Exc_Data[3])
		Ress2 = Exc_Data[4]
		pr = Exchange_Ressources(World,Troupes,Trp,Ress1,Ress2,Qty)
		println(pr)
	catch
		pr = "Veuillez remplir les cases puis cliquer sur envoyer pour effectuer l'échange."
		println(pr)
	end
end

# ╔═╡ d7142012-cb96-468d-b6f1-e05ebe7e5f8f
function Execute_Spread_Soldiers()
	try
		Dep_Terr = parse(Int64,Multiple_Transfer_Data[1])
		Dep_Terr_Strct = Find_Terr(Dep_Terr,World)
		Trp = Dep_Terr_Strct.Troupe
		Arr_Terr_Strg = Multiple_Transfer_Data[2]
		Arr_Terr_Strg_Splited = split(Arr_Terr_Strg, ",")
		Arr_Terr_list = []
			for element in Arr_Terr_Strg_Splited
				flt = parse(Int64,element)
				push!(Arr_Terr_list,flt)
			end
		pr = Spread_Soldiers(World,Troupes,Trp,Dep_Terr,Arr_Terr_list)
		if typeof(pr) == String
			println(pr)
		else
			for element in pr
				println(element)
				println("\n")
			end
		end
	catch
		with_terminal() do
			println("Veuillez remplir les cases puis cliquer sur envoyer pour confirmer les transferts")
		end
	end
end

# ╔═╡ ce4e98e2-75db-49e5-a275-0d16a3def59a
function Execute_Allocate_Ressources()
	try
		AR = parse(Int64,King_Data[2])
		CH = parse(Int64,King_Data[3])
		GU = parse(Int64,King_Data[4])
		HA = parse(Int64,King_Data[5])
		LA = parse(Int64,King_Data[6])
		PA = parse(Int64,King_Data[7])
		PR = parse(Int64,King_Data[8])
		SE = parse(Int64,King_Data[9])
		TE = parse(Int64,King_Data[10])
		VA = parse(Int64,King_Data[11])
		Ress = King_Data[1]
		Allocate_Ressources(World,Troupes,"Archers",Ress,AR)
		Allocate_Ressources(World,Troupes,"Chevaliers",Ress,CH)
		Allocate_Ressources(World,Troupes,"Gueux",Ress,GU)
		Allocate_Ressources(World,Troupes,"Hardis",Ress,HA)
		Allocate_Ressources(World,Troupes,"Lanciers",Ress,LA)
		Allocate_Ressources(World,Troupes,"Paladins",Ress,PA)
		Allocate_Ressources(World,Troupes,"Preux",Ress,PR)
		Allocate_Ressources(World,Troupes,"Servants",Ress,SE)
		Allocate_Ressources(World,Troupes,"Templiers",Ress,TE)
		Allocate_Ressources(World,Troupes,"Vaillants",Ress,VA)
		pr = "Les troupes ont bien été approvisionnées en $Ress."
		print(pr)
	catch
		with_terminal() do
			println("Veuillez remplir les cases puis cliquer sur envoyer pour confirmer les allocations de ressources")
		end
	end
end

# ╔═╡ 43608916-6e72-4cdf-88cf-01c6ad4d81d1
function Execute_AddInterests()
	try
		rte = parse(Float64,Intr_Data[1])
		pr = Add_Interests(Troupes, rte)
		print(pr)
	catch
		with_terminal() do
			println("Veuillez remplir les cases puis cliquer sur envoyer pour confirmer les allocations de ressources")
		end
	end
end

# ╔═╡ 3daf9148-39d2-493c-96be-307d1e402436
if Buy == true
	if Buy_Mil == false
		Execute_Buy()
	elseif Buy_Mil == true
		Execute_Buy_Mil()
	end
elseif Turn == true
	Execute_NewTurn()
elseif Transfer == true
	if Multiple_Transfer == false
		Execute_Transfer()
	elseif Multiple_Transfer == true
		Execute_Spread_Soldiers()
	end
elseif Salt == true
	Execute_Ressource2Salt()
elseif Ass == true
	Execute_Assault()
elseif Exc == true
	Execute_Ressource_Exchange()
elseif EndTurn == true
	Execute_Allocate_Ressources()
elseif Intr == true
	Execute_AddInterests()
end

# ╔═╡ 0f158e7d-ac5f-4832-85a8-a1af5d822e62
md"""### SAUVEGARDER LE JEU

 $(@bind SaveGame CheckBox()) Enregistrer l'état actuel du jeu\
 $(@bind Save CheckBox()) Enregistrement des fiches résumées\
"""

# ╔═╡ f88939de-cd71-4ac7-ad72-6f485029a5c1
if Save == true
	Show_Salt_Info(Troupes)
	Generate_All_txt(World,Troupes)
elseif SaveGame == true
	Show_Salt_Info(Troupes)
	date_du_jour = Dates.today()
    chem = "./Sauvegardes/Sauvegarde_Terr_$date_du_jour.txt"
	chem2 = "./Sauvegardes/Sauvegarde_Trps_$date_du_jour.txt"
	Save_Game(World,Troupes)
	print("Le jeu a bien été sauvegardé dans les fichiers \"Sauvegarde_Terr_$date_du_jour.txt\" et \"Sauvegarde_Trps_$date_du_jour.txt\", à l'intérieur du dossier \"Sauvegardes\"")
end

# ╔═╡ Cell order:
# ╟─c7e31109-3c17-4880-b870-6dd45eb29aa1
# ╟─b9b43e1a-fac4-403c-9bd7-02e9126f0ca8
# ╟─27d48cc9-69bb-49f1-8290-ac821e6f77d9
# ╟─9462050f-92ca-4c33-b1f8-afcc80ede3cf
# ╟─0e22a490-62b1-485b-80b6-6b046062ece8
# ╠═f29c16f1-b8a2-41d4-986b-4b83dec9032d
# ╟─ba82811c-91b4-4355-97ce-ea731c2000c9
# ╠═61fbec2c-1003-4ccf-a588-0f5b927226f1
# ╟─4f4b516e-00c6-4dc3-aee3-7fb8c1a1b8cf
# ╟─2bebe9c0-b5af-4336-825a-9add6581d21d
# ╟─1d6eba18-9d51-4c96-975d-bdc9c5d2e861
# ╟─60a165a8-4e65-4948-8fd7-d8c744051037
# ╟─0b8cd34c-02e7-4559-a687-bc1a8f020ddf
# ╟─933a08ef-df41-4f9d-b755-2f467dbad556
# ╟─03951448-2744-4668-a5c0-13a3cb57c8db
# ╟─2fa4706b-f1ca-4fa0-8568-b0512936d8b2
# ╟─000d6c33-dc9f-4ddb-8439-20d1a7a98d82
# ╟─4e2210be-c52e-42b7-9bd8-3ed46e62a4e3
# ╟─28d3f46d-3258-4c9b-bffa-13d9f464cbd5
# ╟─abd800af-4f8f-48bb-9588-f43c75957605
# ╟─dc8eff81-5e94-4cb2-8e78-b822f307a120
# ╟─4782e4f3-a8ba-459e-8668-e82330ae7b0d
# ╟─25f01e6a-303f-45e9-b860-d53cb12c2525
# ╟─b04c0ee0-ec1d-4af1-ab36-2f3e1fdf918b
# ╟─51fdab25-7c05-432d-a388-7949cfeddb3e
# ╟─6ed6bcf1-4b61-4adf-ae18-22959bac3f1f
# ╟─57d50a15-7578-4348-bc38-5e4196bf26c6
# ╟─085d3212-a58f-49e6-925c-2fd134ad8471
# ╟─88bf0967-64e5-4e4d-a891-374f52093b92
# ╟─ce1c8eb9-4ad7-4bb6-ac51-394cd187854a
# ╟─2194282d-5203-4d1d-965e-b40469064624
# ╟─f2a72f90-7841-4ccd-a09d-2c94f54476e8
# ╟─f209d063-9403-4578-8fd8-f521f97089d6
# ╟─3ffe698b-10f7-4164-93f5-d9338775cc74
# ╟─fbd3a901-c2b2-4e3f-8610-2da7a12c7b13
# ╟─6c0a40cd-d316-42bb-955a-00f2afdbefa0
# ╟─49d6deec-8929-4e17-9ba7-a23cec4de568
# ╟─554d8c87-8a34-4ca2-98ff-443dc8226381
# ╟─3d3cc7ed-cf7a-4b4f-98e9-95359ad21cef
# ╟─5882f6dc-0e89-418a-897b-921d233e74e8
# ╟─2811036d-a050-4b7b-8d9e-5d6a67aacc38
# ╟─5aef7700-82be-4c8d-9837-f6ffce9f0dbb
# ╟─171d8915-ec10-4afe-9705-6b10f0332213
# ╟─d45625d4-9e8f-4724-941e-e9b514a27651
# ╟─82ce8603-027a-4197-8d9e-d6c471e416ed
# ╟─ac9c1cb6-78ad-4387-83c5-c83522f5bb6d
# ╟─4a58cec4-778c-4594-ae25-2492acddc68b
# ╟─15ccf590-a109-4e7f-aa5a-b756d6fccbe9
# ╟─02353a04-545f-4e79-b5b3-b93b441138ff
# ╟─0610f156-775c-4f71-8d28-c284770dabf2
# ╟─f5019805-05db-4c60-b87b-de6f39ac5556
# ╟─166ba06c-8fda-44a1-8d83-2c8bd90e3433
# ╟─470479de-fd0c-4a93-826b-82665a9ede0b
# ╟─40c0eae6-51cb-4c34-bc50-d4d1de2b1086
# ╟─eafbff43-6241-42b2-a27f-1f2d68ed6415
# ╟─2e77c3fc-94bd-4dfe-a8b9-4302db6b85fb
# ╟─3b763c2f-83d8-4be6-9fb5-e6ce1881db52
# ╟─8a577e66-9a7a-49e6-abbf-b0f615bab9ed
# ╟─1e15b72a-b0be-4045-961b-5e8de4cc9b4f
# ╟─ca705873-8374-4baa-a4c4-65d1ccdb5698
# ╟─a1b4005e-6e10-45ee-b018-6ff5c0a1a4a9
# ╟─8bb403e2-83e7-49b7-8c3c-b0d6c97f4aed
# ╟─31f0c518-740d-4d6b-be63-ee953d6f477b
# ╟─ec047408-2525-4947-bc4c-2df0ac126c7e
# ╟─3f554a7d-8d0c-4258-ab9e-2a88d41fdda1
# ╟─662471db-b727-4371-9efd-0f2d5e03e4be
# ╟─fc69d958-b5e0-45b8-bdcc-6ca858059fc0
# ╟─d7142012-cb96-468d-b6f1-e05ebe7e5f8f
# ╟─ce4e98e2-75db-49e5-a275-0d16a3def59a
# ╟─43608916-6e72-4cdf-88cf-01c6ad4d81d1
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
# ╟─0f158e7d-ac5f-4832-85a8-a1af5d822e62
# ╟─f88939de-cd71-4ac7-ad72-6f485029a5c1
