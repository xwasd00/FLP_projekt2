# Logický projekt do FLP: Hamiltonovská kružnice
- Autor: Michal Sova (xsovam00@stud.fit.vutbr.cz)

## Implementace
Veškerá implementace je v souboru `main.pl`. 
- Jako vstupní cíl slouží klauzule `main`.
- Klauzule `read_input` načte vstup. 
- Klauzule `parse_points_edges` rozparsuje seznam řádků, hrany si uloží do báze znalostí a body si uloží do seznamu. 
- Klauzule `get_cycles` pak řeší danou úlohu pro načtený graf pomocí backtrakingu. Uloží si první bod jako počáteční stav, který následné expanduje (zkontroluje jestli k neprozkoumaným bodům vede hrana) a prochází všechny expandované body. Po navštívení všech bodů algoritmus zkontroluje existenci hrany posledního navštíveného bodu s počétečním. Pokud existuje hrana, byla nalezena Hamiltonovská kružnice. Algoritmus v každém případě pokračuje dál dokud nespotřebuje všechny možné cesty. 
- Klauzule `print_cycles` nakonec vytiskne kružnice na standardní výstup.

## Testy
V adresáři `test/` se nachází pár vzorových vstupních souborů s přibližnou dobou výpočtu:
- `test1.in`: 1s
- `test2.in`: 1s