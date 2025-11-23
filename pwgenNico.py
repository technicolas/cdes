#!/usr/bin/env python3
import argparse
import string
import sys
from secrets import choice

AMBIGUOUS = set("l1I0OoS5B8Z2")
SYMBOLS_SAFE = "!@#$%^&*()-_=+[]{};:,./?~"

CHARSETS = {
    "simple": {
        "classes": [string.ascii_lowercase],
        "desc": "Minuscules uniquement"
    },
    "medium": {
        "classes": [string.ascii_lowercase, string.digits],
        "desc": "Minuscules + chiffres"
    },
    "strong": {
        "classes": [string.ascii_lowercase, string.ascii_uppercase, string.digits],
        "desc": "Minuscules + majuscules + chiffres"
    },
    "ultra": {
        "classes": [string.ascii_lowercase, string.ascii_uppercase, string.digits, SYMBOLS_SAFE],
        "desc": "Minuscules + majuscules + chiffres + symboles"
    },
}

VERSION = "pwgenNico 1.0.0"

MAN_PAGE = """\
PWGEN_LIKE(1)                User Commands               PWGEN_LIKE(1)

NAME
       pwgenNico - Générateur de mots de passe compliqués façon pwgen

SYNOPSIS
       pwgenNico.py [OPTIONS]

DESCRIPTION
       pwgenNico.py est un utilitaire en Python qui génère des mots
       de passe aléatoires et sécurisés, inspiré de la commande pwgen
       sous Linux. Il permet de définir la longueur, le nombre de mots
       de passe à générer, le niveau de complexité, et d’exclure les
       caractères ambigus.

       Par défaut, sans aucun paramètre, le programme génère 10 mots
       de passe de 16 caractères avec un niveau de complexité "strong".

OPTIONS
       -n, --count N
              Nombre de mots de passe à générer.
              Défaut : 10

       -l, --length N
              Longueur de chaque mot de passe.
              Défaut : 16

       -c, --complexity {simple,medium,strong,ultra}
              Niveau de complexité :
                 simple  : minuscules uniquement
                 medium  : minuscules + chiffres
                 strong  : minuscules + majuscules + chiffres
                 ultra   : minuscules + majuscules + chiffres + symboles
              Défaut : ultra

       -r, --require-each-class
              Exiger au moins un caractère de chaque catégorie
              (selon le niveau de complexité choisi).

       -A, --avoid-ambiguous
              Éviter les caractères ambigus (l, 1, I, 0, O, o, S, 5,
              B, 8, Z, 2).

       -m, --man
              Afficher cette page de documentation et quitter.

       -v, --version
              Afficher la version et quitter.

EXAMPLES
       Générer 10 mots de passe compliqués (par défaut) :
              pwgenNico.py

       Générer 20 mots de passe forts de 24 caractères sans ambiguïtés :
              pwgenNico.py -n 20 -l 24 -c strong -A -r

       Générer 5 mots de passe ultra de 32 caractères avec symboles :
              pwgenNico.py -n 5 -l 32 -c ultra -r

AUTHOR
       ZANDARIN Nicolas.

COPYRIGHT
       Licence libre. Utilisation, modification et distribution
       autorisées.
"""

def build_pool(complexity: str, avoid_ambiguous: bool) -> list[str]:
    classes = CHARSETS[complexity]["classes"]
    pool = "".join(classes)
    if avoid_ambiguous:
        pool = "".join(ch for ch in pool if ch not in AMBIGUOUS)
    return list(pool)

def ensure_each_class(password: list[str], classes: list[str], avoid_ambiguous: bool) -> None:
    for charset in classes:
        usable = [ch for ch in charset if not avoid_ambiguous or ch not in AMBIGUOUS]
        if usable:
            idx = choice(range(len(password)))
            password[idx] = choice(usable)

def generate_password(length: int, complexity: str, require_each_class: bool, avoid_ambiguous: bool) -> str:
    classes = CHARSETS[complexity]["classes"]
    pool = build_pool(complexity, avoid_ambiguous)
    pwd_list = [choice(pool) for _ in range(length)]
    if require_each_class:
        ensure_each_class(pwd_list, classes, avoid_ambiguous)
    return "".join(pwd_list)

def generate_passwords(count: int, length: int, complexity: str, require_each_class: bool, avoid_ambiguous: bool) -> list[str]:
    return [generate_password(length, complexity, require_each_class, avoid_ambiguous) for _ in range(count)]

def main():
    parser = argparse.ArgumentParser(
        description="Générateur de mots de passe façon pwgen."
    )
    parser.add_argument("-n", "--count", type=int, default=10,                          # Nombre de pwd à générer à générer par défaut.
                        help="Nombre de mots de passe à générer (default: 10)")
    parser.add_argument("-l", "--length", type=int, default=16,                         # Nombre de caractères à générer par défaut.
                        help="Longueur de chaque mot de passe (default: 16)")
    parser.add_argument("-c", "--complexity", choices=list(CHARSETS.keys()), default="ultra",
                        help="Niveau de complexité: simple, medium, strong, ultra (default: ultra)")
    parser.add_argument("-r", "--require-each-class", action="store_true",
                        help="Exiger au moins un caractère de chaque catégorie")
    parser.add_argument("-A", "--avoid-ambiguous", action="store_true",
                        help="Éviter les caractères ambigus")
    parser.add_argument("-m", "--man", action="store_true",
                        help="Afficher la page de documentation et quitter")
    parser.add_argument("-v", "--version", action="store_true",
                        help="Afficher la version et quitter")

    args = parser.parse_args()

    if args.man:
        print(MAN_PAGE)
        sys.exit(0)

    if args.version:
        print(VERSION)
        sys.exit(0)

    passwords = generate_passwords(
        count=args.count,
        length=args.length,
        complexity=args.complexity,
        require_each_class=args.require_each_class,
        avoid_ambiguous=args.avoid_ambiguous
    )
    for p in passwords:
        print(p)

if __name__ == "__main__":
    main()