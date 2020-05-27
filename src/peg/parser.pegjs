
Document
  = Item*

Item
  = Tag
  / Template
  / Text;

Tag = '<' inner:[^>]+ '>' { return { kind: 'tag', val: inner.join('') }; };

TermI
  = inner:[^,{}]+ { return { kind: 'text', val: inner.join('') }}

Term5a = TermI ',' TermI ',' TermI ',' TermI ',' TermI
Term4a = TermI ',' TermI ',' TermI ',' TermI
Term3a = TermI ',' TermI ',' TermI
Term2a = TermI ',' TermI
Term1a = TermI

TermInner
  = Term5a
  / Term4a
  / Term3a
  / Term2a
  / Term1a
  / term:Template;

Template = '{' inner:TermInner+ '}' { return { kind: 'template', val: inner }; };

Text = tx:[^<{]+ { return { kind: 'text', val: tx.join('') }; }
