def subtract_files(file1, file2, result_file):
    # Open files in read mode
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        lines_file1 = f1.readlines()
        lines_file2 = f2.readlines()

    # Check if files have the same number of lines
    if len(lines_file1) != len(lines_file2):
        print("The files don't have the same number of lines.")
    else:
        # Open result file in write mode
        with open(result_file, 'w') as result:
            for line1, line2 in zip(lines_file1, lines_file2):
                # Convert lines to floating point numbers
                number1 = float(line1.strip())
                number2 = float(line2.strip())
                
                # Subtract values and write the result to the result file
                result.write(str(number1 - number2) + "\n")

        print("Operation completed. The result has been saved in", result_file)

def subtract_and_save_files(names_list):
    all_reports = []  # List to store all reports

    for name in names_list:
        # Chemins des fichiers d'entrée et de sortie
        file1 = f"./Catastrophes/Sit_Pro_Cata_{name}.txt"
        file2 = f"./Catastrophes/Sit_Post_Cata_{name}.txt"
        result_file = f"./Catastrophes/Diff_Cata_{name}.txt"

        # Ouvrir les fichiers et soustraire les valeurs
        subtract_files(file1, file2, result_file)

        # Ajouter le rapport à la liste des rapports
        with open(result_file, 'r') as f:
            lines = f.readlines()
            report = f"ÉTAT DES PERTES - {name.upper()}:\n"
            for desc, line in zip(descriptions, lines):
                report += f"{desc}: {line.strip()}\n"
            all_reports.append(report)

    # Enregistrer tous les rapports dans un seul fichier
    with open("./Catastrophes/General_Report.txt", 'w') as general_report:
        # Écrire le contenu du fichier King_Message.txt
        with open("./Catastrophes/King_Message.txt", 'r') as king_message:
            general_report.write(king_message.read())
            general_report.write("\n\n")
        
        # Écrire tous les rapports des troupes
        for report in all_reports:
            general_report.write(report)
            general_report.write("\n")

    print("All reports have been generated and saved in General_Report.txt.")

# Utilisation des fonctions
descriptions = [
        "Quantité de territoires perdus ",
        "Nombre de soldats tués ",
        "Nombre de bateaux détruits ",
        "Pertes en minerais ",
        "Pertes en blé ",
        "Pertes en bois ",
        "Pertes en pierre "
    ]
Troupe_Names = ["Archers", "Hardis", "Paladins","Lanciers","Gueux","Preux","Vaillants","Chevaliers","Templiers","Servants"]
subtract_and_save_files(Troupe_Names)