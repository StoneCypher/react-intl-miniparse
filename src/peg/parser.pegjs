Document
  = Item*

Item
  = Tag
  / Template
  / Text;

Tag = '<' inner:[^>]+ '>' { return { kind: 'tag', val: inner.join('') }; };

TermInner
  = inner:[^{}]+ { return { kind: 'text', val: inner.join('') }}
  / term:Template;

Template = '{' inner:TermInner+ '}' { return { kind: 'template', val: inner }; };

Text = tx:[^<{]+ { return { kind: 'text', val: tx.join('') }; }