# react-intl-miniparse

Do a craptacular job of parsing the react-intl templates, so that you can do text 
transforms without transforming the template controls



<br/><br/>

## ... what?

Okay, so, let's consider the case of automatically creating a test language to test 
that all the text in an app actually has been extracted into a string table.

A quick first-pass way of doing this is taking the string table, and replacing the
characters inside it with some unicode symbol which is visibly very different but
still readable, such as the `ring characters` like U+24B6 Ⓐ or whatever.

And if your string table is `Hello, World` you get `Ⓗⓔⓛⓛⓞ, ⓦⓞⓡⓛⓓ!` in 
response.  And then you can just use a tooled browser like 
[playwright](https://github.com/microsoft/playwright) or 
[puppeteer](https://github.com/puppeteer/puppeteer) or whatever, assert that there's
no `[a-zA-Z]` on the page, and you're done, right?



<br/><br/>

## (finger raised guy)

The problem is, that fails most of the examples in the basic messages example.

```javascript
const messages = {
  simple: 'Hello world',
  placeholder: 'Hello {name}',
  date: 'Hello {ts, date}',
  time: 'Hello {ts, time}',
  number: 'Hello {num, number}',
  plural: 'I have {num, plural, one {# dog} other {# dogs}}',
  select: 'I am a {gender, select, male {boy} female {girl}}',
  selectordinal: `I am the {order, selectordinal, 
        one {#st person} 
        two {#nd person}
        =3 {#rd person} 
        other {#th person}
    }`,
  richtext: 'I have <bold>{num, plural, one {# dog} other {# dogs}}</bold>',
  richertext:
    'I have & < &nbsp; <bold>{num, plural, one {# & dog} other {# dogs}}</bold>',
  unicode: 'Hello\u0020{placeholder}',
};
```

It's going to transform `Hello {num, number}` to `Ⓗⓔⓛⓛⓞ {ⓝⓤⓜ, ⓝⓤⓜⓑⓔⓡ}`, 
not `Ⓗⓔⓛⓛⓞ {num, number}` like we want.





<br/><br/>

## Tougher example

`I am a {gender, select, male {boy} female {girl}}` should remove `gender`, 
`select`, `male`, and `female` from consideration, because they're symbols, but 
translate `I am a`, `boy`, and `girl`.

We need the contents from `want`, but a character for character replacement will
give us the contents from `dumb` instead.

```javascript
const orig = 'I am a {gender, select, male {boy} female {girl}}',
      want = 'Ⓘ ⓐⓜ ⓐ {gender, select, male {ⓑⓞⓨ} female {ⓖⓘⓡⓛ}}',
      dumb = 'Ⓘ ⓐⓜ ⓐ {ⓖⓔⓝⓓⓔⓡ, ⓢⓔⓛⓔⓒⓣ, ⓜⓐⓛⓔ {ⓑⓞⓨ} ⓕⓔⓜⓐⓛⓔ {ⓖⓘⓡⓛ}}';
```

In order to get the contents from `want`, we need a simple parser and compiler, 
instead, which has the ability to use your transforming function on just the text
parts, and that's this.
