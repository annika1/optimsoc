OBJDIR := .

all: $(OBJDIR)/bin2vmem $(OBJDIR)/optimsoc-pgas-binary $(OBJDIR)/pkg-config

$(OBJDIR)/bin2vmem: bin2vmem.c
	gcc -Wall -o $(OBJDIR)/bin2vmem bin2vmem.c

$(OBJDIR)/optimsoc-pgas-binary:
	cp optimsoc-pgas-binary $(OBJDIR)/optimsoc-pgas-binary

$(OBJDIR)/pkg-config:
	cp pkg-config $(OBJDIR)/pkg-config

clean:
	rm $(_OBJS)

.PHONY: clean

