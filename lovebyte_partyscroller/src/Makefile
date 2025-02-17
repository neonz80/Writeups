NAME = scroller
LAUNCHER_NAME = "PARTY"
CODE_NAME = "SCROLLER"

all : $(NAME).tap

$(NAME).bin : $(NAME).asm Makefile
	sjasmplus --nologo --sym=$(NAME).sym --raw=$@ $<

$(NAME).tap : $(NAME).bin Makefile
	python3 ../../tools/create_tap.py -o $@ -s $(NAME).sym -l $(LAUNCHER_NAME) -c $(CODE_NAME) $<

.PHONY: clean
clean:
	$(RM) -f $(NAME).bin $(NAME).tap $(NAME).sym
