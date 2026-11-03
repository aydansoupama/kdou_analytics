-- 1) a) On veut vérifier les coordonnées des clients parisiens : liste triée par société. 
SELECT
    Clientele.Societe,
    Clientele.Contact,
    Clientele.MailCli,
    Clientele.Tel
FROM
    Clientele
WHERE
    Clientele.Ville = 'Paris'
ORDER BY
    Clientele.Societe;

-- 1) b) Quels sont les produits de provenance des Etats-Unis avec un cout de moins de 25€ ? On veut les connaître noms et prix, nom du fournisseur et ville.
SELECT
    Produit.NomProd,
    Produit.CoutAchat,
    Fournisseur.Societe,
    Fournisseur.Ville
FROM
    (
        Produit
        INNER JOIN Fournisseur ON Produit.NoFour = Fournisseur.NoFour
    )
    INNER JOIN Pays ON Fournisseur.NoPays = Pays.NoPays
WHERE
    Produit.CoutAchat < 25
    AND Pays.PaysFR = "Etats-Unis"
ORDER BY
    Produit.CoutAchat DESC,
    Produit.NomProd;

-- 1) c) c. Quels sont les produits (avec fournisseur et pays de provenance) de catégorie viandes ou poissons ayant un coût d’achat de plus de 50€ ?
SELECT
    Produit.NomProd,
    Produit.CoutAchat,
    Fournisseur.Societe,
    Pays.PaysFR,
    Categorie.NomCateg
FROM
    (
        (
            Produit
            INNER JOIN Fournisseur ON Produit.NoFour = Fournisseur.NoFour
        )
        INNER JOIN Pays ON Pays.NoPays = Fournisseur.NoPays
    )
    INNER JOIN Categorie ON Produit.CodeCateg = Categorie.CodeCateg
WHERE
    Categorie.NomCateg IN ("Viandes", "Poissons et fruits de mer")
    AND Produit.CoutAchat > 50
ORDER BY
    Produit.CoutAchat DESC,
    Pays.PaysFR,
    Produit.NomProd;

-- 1) d) Quels fournisseurs proposent de la viande ou du poisson ?
SELECT DISTINCT
    Fournisseur.Societe
FROM
    (
        Fournisseur
        INNER JOIN Produit ON Fournisseur.NoFour = Produit.NoFour
    )
    INNER JOIN Categorie ON Produit.CodeCateg = Categorie.CodeCateg
WHERE
    Categorie.NomCateg IN ("Viandes", "Poissons et fruits de mer")
ORDER BY
    Fournisseur.Societe;

-- 1) e) Quels fournisseurs proposent de la viande et du poisson ?
SELECT
    Fournisseur.Societe
FROM
    Fournisseur
WHERE
    Fournisseur.NoFour IN (
        SELECT DISTINCT
            Fournisseur.NoFour
        FROM
            (
                Fournisseur
                INNER JOIN Produit ON Fournisseur.NoFour = Produit.NoFour
            )
            INNER JOIN Categorie ON Produit.CodeCateg = Categorie.CodeCateg
        WHERE
            Categorie.NomCateg IN ("Viandes")
    )
    AND Fournisseur.NoFour IN (
        SELECT DISTINCT
            Fournisseur.NoFour
        FROM
            (
                Fournisseur
                INNER JOIN Produit ON Fournisseur.NoFour = Produit.NoFour
            )
            INNER JOIN Categorie ON Produit.CodeCateg = Categorie.CodeCateg
        WHERE
            Categorie.NomCateg IN ("Poissons et fruits de mer")
    )
ORDER BY
    Fournisseur.Societe;

-- 1) f) Quels sont les produits conditionnés dans du carton ou dans du verre ?
SELECT
    Produit.NomProd,
    Produit.QteParUnit
FROM
    Produit
WHERE
    Produit.QteParUnit LIKE '*bouteille*'
    OR Produit.QteParUnit LIKE '*verre*'
ORDER BY
    Produit.NomProd,
    Produit.QteParUnit;

--1) g) Donner les 3 dernières commandes du client Max Deschamps ?
SELECT
    TOP 3 *
FROM
    Commande
    INNER JOIN Clientele ON Commande.CodeCli = Clientele.CodeCli
WHERE
    Clientele.Contact = 'Max Deschamps'
ORDER BY
    Commande.DateCde DESC;

-- 1) h) Quels fournisseurs ne proposent que des desserts ? 
SELECT
    Fournisseur.NoFour,
    Fournisseur.Societe
FROM
    Fournisseur
WHERE
    Fournisseur.NoFour IN (
        SELECT
            Fournisseur.NoFour
        FROM
            (
                Fournisseur
                INNER JOIN Produit ON Fournisseur.NoFour = Produit.NoFour
            )
            INNER JOIN Categorie ON Produit.CodeCateg = Categorie.CodeCateg
        WHERE
            Categorie.NomCateg IN ("Desserts")
    )
    AND Fournisseur.NoFour NOT IN (
        SELECT
            Fournisseur.NoFour
        FROM
            (
                Fournisseur
                INNER JOIN Produit ON Fournisseur.NoFour = Produit.NoFour
            )
            INNER JOIN Categorie ON Produit.CodeCateg = Categorie.CodeCateg
        WHERE
            Categorie.NomCateg NOT IN ("Desserts")
    )
ORDER BY
    Fournisseur.Societe;

-- i. Quels fournisseurs hors France n’ont pas encore de produits au catalogue de Kdou ?
SELECT
    Fournisseur.NoFour,
    Fournisseur.Societe,
    Pays.PaysFR
FROM
    Fournisseur
    INNER JOIN Pays ON Fournisseur.NoPays = Pays.NoPays
WHERE
    (NOT Pays.PaysFR = 'France')
    AND Fournisseur.NoFour NOT IN (
        SELECT
            Produit.NoFour
        FROM
            Produit
    )
ORDER BY
    Fournisseur.Societe
    -- j. Pour optimiser les livraisons, on veut savoir quels couples de clients sont situés à Paris.
SELECT
    C1.CodeCli,
    C1.Societe,
    C2.CodeCli,
    C2.Societe
FROM
    Clientele as C1
    INNER JOIN Clientele as C2 ON C1.CodeCli = C2.CodeCliPart
WHERE
    C1.Ville = 'Paris'
    AND C2.Ville = 'Paris'
    AND C1.CodeCli < C2.CodeCli
ORDER BY
    C1.Societe,
    C2.Societe;

-- 2) Dans une réflexion en lien avec l’origine de ses produits : On veut comme indicateur le CA total généré à ce jour avec les fournisseurs de l’UE ? 
SELECT
    SUM(
        Produit.CoutAchat * Categorie.CoefMarge * DetailCommande.Quantité
    ) as CA_Total
FROM
    (
        (
            (
                Fournisseur
                INNER JOIN Pays ON Fournisseur.NoPays = Pays.NoPays
            )
            INNER JOIN Produit ON Produit.NoFour = Fournisseur.NoFour
        )
        INNER JOIN Categorie ON Produit.CodeCateg = Categorie.CodeCateg
    )
    INNER JOIN DetailCommande ON Produit.RefProd = DetailCommande.[Réf produit]
WHERE
    Pays.UE = 'Membre'

-- 3) Dans une réflexion en lien avec la santé : On veut comme indicateur le chiffre d’affaire généré (montant total des ventes) annuel pour les catégories desserts ou boissons.  

SELECT
    SUM(
        Produit.CoutAchat * Categorie.CoefMarge * DetailCommande.Quantité
    ) as CA_Boissons_Desserts
FROM
    (
        Produit ON Produit.NoFour = Fournisseur.NoFour
        INNER JOIN Categorie ON Produit.CodeCateg = Categorie.CodeCateg
    )
    INNER JOIN DetailCommande ON Produit.RefProd = DetailCommande.[Réf produit]

WHERE Categorie.NomCateg IN ("Desserts", "Boissons")


-- 4) Dans une réflexion en lien avec l’offre commerciale : Calcul de l’indicateur nombre de produits carnés non commandés actuellement ? 

SELECT
    *
FROM
    (
           Produit
        INNER JOIN Categorie ON Produit.CodeCateg = Categorie.CodeCateg
    ) LEFT JOIN DetailCommande ON Produit.RefProd = DetailCommande.[Réf produit]
    WHERE DetailCommande.[Réf produit] IS NULL
    AND Categorie.NomCateg IN ("Viandes")

-- 5) 5) Dans une réflexion sur le partenariat client : A-t-on des clients pilotes d’un réseau partenaire ayant autant de commandes que les clients partenaires ?  

SELECT
    COUNT(*)
FROM
    (
        SELECT
            Pilote.CodeCli as CodePilote,
            COUNT(*) as nombre_commande_pilotes
        FROM
            Commande AS C
            INNER JOIN (
                SELECT DISTINCT
                    Pilote.CodeCli
                FROM
                    Clientele as Pilote
                    INNER JOIN Clientele as Partenaire ON Pilote.CodeCli = Partenaire.CodeCliPart
            ) as Pilote ON C.CodeCli = Pilote.CodeCli
        GROUP BY
            Pilote.CodeCli
    ) as total_pilote
    INNER JOIN (
        SELECT
            Partenaire.CodeCliPart as CodePilote,
            COUNT(*) as nombre_commande_partenaires
        FROM
            Clientele as Partenaire
            INNER JOIN Commande ON Partenaire.CodeCli = Commande.CodeCli
        WHERE
            Partenaire.CodeCliPart IS NOT NULL
        GROUP BY
            Partenaire.CodeCliPart
    ) as total_partenaire ON total_pilote.CodePilote = total_partenaire.CodePilote
WHERE
    total_pilote.nombre_commande_pilotes = total_partenaire.nombre_commande_partenaires