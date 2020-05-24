# react-intl-miniparse

Do a craptacular job of parsing the react-intl templates, so that you can do text 
transforms without transforming the template controls





<br/><br/>

## ... what?

Got an internationalization file?  Need to mechanically transform it?  Ha, you're
screwed!  Or not, there's this silly little thing.

Suppose you have a website.  Suppose you want to make it available in multiple 
languages.  The most common approach is to make the site with internationalization
files.  Which means instead of writing

```html
<h1>Welcome to my website!</h1>
<p>Buy things</p>
```

You might write

```html
<h1>{welcome_greeting}</h1>
<p>{buy_things_command}</p>
```

```javascript
const english = {
  welcome_greeting   : 'Welcome to my website!',
  buy_things_command : 'Buy things'
};

const french = {
  welcome_greeting   : 'Bienvenue sur mon site web!',
  buy_things_command : 'Acheter des choses'
};

const hebrew = {
  welcome_greeting   : 'ברוך הבא לאתר שלי!',
  buy_things_command : 'לקנות דברים'
};

const swahili = {
  welcome_greeting   : 'Karibu kwenye wavuti yangu!',
  buy_things_command : 'Nunua vitu'
};

const english_uk = {
  welcome_greeting   : 'Weulcomme to my webbe site!',
  buy_things_command : 'Prithee purchase here'
};

const english_pirate = {
  welcome_greeting   : "Ahhr, matey, and enjoy not walkin' th' plank!",
  buy_things_command : "Put down y'r doubloons"
};



const languages = {
  en: [ us: english, uk: english_uk, pi: english_pirate ],
  he: [ he: hebrew ],
  fr: [ fr: french ],
  sw: [ sw: swahili ]
};
```

And then your website can just put up the requested language as appropriate.  Right?

... right?





<br/><br/>

## ... what?

The thing is, testing that is really hard.  There's always some string you forget to
extract, that is only in one language, making you look bad.

So, let's consider the case of automatically creating a test language to test 
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

That is to say, we don't want to transform every character; we only want to 
transform the parts that represent user text.





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
