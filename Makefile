SRC=*.pl
PROJ=flp21-log
LOGIN=xsovam00
ZIP=flp-log-$(LOGIN).zip
TESTDIR=test/
TMPDIR=tmp-flp/

.PHONY:$(PROJ)

$(PROJ):$(SRC)
	swipl --stand_alone=true -q -g main -o $(PROJ) -c $(SRC)

run:$(PROJ)
	./$(PROJ) < $(TESTDIR)test1.in

merlin:pack
	ssh merlin "mkdir -p ~/$(TMPDIR)"
	scp $(ZIP) merlin:~/$(TMPDIR)
	ssh merlin "cd $(TMPDIR) && unzip -o $(ZIP) && make run"
	ssh merlin "cd .. && rm -rf $(TMPDIR)"

clean:
	rm -rf $(PROJ) $(ZIP)


pack: clean
	zip -r $(ZIP) $(SRC) README.md Makefile $(TESTDIR)
