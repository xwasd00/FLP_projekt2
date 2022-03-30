# Logický projekt do FLP: Hamiltonovská kružnice
- Autor: Michal Sova (xsovam00@stud.fit.vutbr.cz)

## Implementace
Veškerá implementace je v souboru `main.pl`. 
- Jako vstupní cíl slouží klauzule `main`.
- Klauzule `read_input` načte vstup. 
- Klauzule `parse_points_edges` rozparsuje seznam řádků, hrany si uloží do báze znalostí a body si uloží do seznamu. 
- Klauzule `get_cycles` pak řeší danou úlohu pro načtený graf pomocí vygenerování poloviny permutací všech vrcholů kromě počátečního, jelikož pro graf s N plně propojenými vrcholy existuje (N - 1)!/2 Ham. kružnic. Například pro plně propojený graf se 4 vrcholy [A,B,C,D], se ignoruje A a vygeneruje se seznam permutací [[B,C,D],[C,B,D],[C,D,B]]. Následně algoritmus prochází seznam permutací a snaží se najít cestu (seznam hran) od počátečního vrchou, přes všechny vrcholy dané permutace, až opět k počátečnímu vrcholu. Algoritmus v tomto případě přidá cestu, jak daleko se dostal (je možné, že cesta byde jen část kružnice; v tomto případě klauzule `print_cycles` dané částečné cesty ignoruje).
- Klauzule `print_cycles` nakonec vytiskne všechny validní cesty tvořící Ham. kružnici (o velikosti N) na standardní výstup.

## Testy
V adresáři `test/` se nachází pár vzorových vstupních souborů s přibližnou dobou výpočtu (použití příkazu `time ./flp21-fun <...`):
- `test1.in`: méně jak 1s
- `test2.in`: méně jak 1s
- `test3.in`: 3-6s (přesměrování stdout do souboru pak méně jak 1s); obsahuje graf s 9 plně propojenými vrcholy -> vygeneruje se (9-1)!/2 = 20160 Ham. kružnic