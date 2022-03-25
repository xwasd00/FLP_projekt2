SRC=*.pl
PROJ=flp21-log
LOGIN=xsovam00
ZIP=flp-fun-$(LOGIN).zip

.PHONY:$(PROJ)

$(PROJ):$(SRC)
	swipl --stand_alone=true -q -g main -o $(PROJ) -c $(SRC)

run:$(PROJ)
	./$(PROJ) < test.txt

clean:
	rm -rf $(PROJ) $(ZIP)

pack: clean
	zip -r $(ZIP) $(SRC) README.md Makefile
