describe "XML grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-xml")

    runs ->
      grammar = atom.grammars.grammarForScopeName("text.xml")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "text.xml"

  it "tokenizes comments in internal subsets correctly", ->
    lines = grammar.tokenizeLines """
      <!DOCTYPE root [
      <a> <!-- [] -->
      <b> <!-- [] -->
      <c> <!-- [] -->
      ]>
    """

    expect(lines[1][1]).toEqual value: '<!--', scopes: ['text.xml', 'meta.tag.sgml.doctype.xml', 'meta.internalsubset.xml', 'comment.block.xml', 'punctuation.definition.comment.xml']
    expect(lines[2][1]).toEqual value: '<!--', scopes: ['text.xml', 'meta.tag.sgml.doctype.xml', 'meta.internalsubset.xml', 'comment.block.xml', 'punctuation.definition.comment.xml']
    expect(lines[3][1]).toEqual value: '<!--', scopes: ['text.xml', 'meta.tag.sgml.doctype.xml', 'meta.internalsubset.xml', 'comment.block.xml', 'punctuation.definition.comment.xml']

  it "tokenizes empty element meta.tag.no-content.xml", ->
    {tokens} = grammar.tokenizeLine('<n></n>')
    expect(tokens[0]).toEqual value: '<',   scopes: ['text.xml', 'meta.tag.no-content.xml', 'punctuation.definition.tag.xml']
    expect(tokens[1]).toEqual value: 'n',   scopes: ['text.xml', 'meta.tag.no-content.xml', 'entity.name.tag.xml', 'entity.name.tag.localname.xml']
    expect(tokens[2]).toEqual value: '>',   scopes: ['text.xml', 'meta.tag.no-content.xml', 'punctuation.definition.tag.xml']
    expect(tokens[3]).toEqual value: '</',  scopes: ['text.xml', 'meta.tag.no-content.xml', 'punctuation.definition.tag.xml']
    expect(tokens[4]).toEqual value: 'n',   scopes: ['text.xml', 'meta.tag.no-content.xml', 'entity.name.tag.xml', 'entity.name.tag.localname.xml']
    expect(tokens[5]).toEqual value: '>',   scopes: ['text.xml', 'meta.tag.no-content.xml', 'punctuation.definition.tag.xml']
    
  it "tokenizes attribute-name of multi-line tag", ->
    linesWithIndent = grammar.tokenizeLines """
      <el
        attrName="attrValue">
      </el>
    """
    expect(linesWithIndent[1][1]).toEqual value: 'attrName', scopes: ['text.xml', 'meta.tag.xml', 'entity.other.attribute-name.localname.xml']
    
    linesWithoutIndent = grammar.tokenizeLines """
      <el
attrName="attrValue">
      </el>
    """
    expect(linesWithoutIndent[1][0]).toEqual value: 'attrName', scopes: ['text.xml', 'meta.tag.xml', 'entity.other.attribute-name.localname.xml']

  it "tokenizes attribute-name.namespace contains period", ->
    lines = grammar.tokenizeLines """
      <el name.space:attrName="attrValue">
      </el>
    """
    expect(lines[0][3]).toEqual value: 'name.space', scopes: ['text.xml', 'meta.tag.xml', 'entity.other.attribute-name.namespace.xml']

  it "tokenizes attribute-name.namespace contains East-Asian Kanji", ->
    lines = grammar.tokenizeLines """
      <el 名前空間名:attrName="attrValue">
      </el>
    """
    expect(lines[0][3]).toEqual value: '名前空間名', scopes: ['text.xml', 'meta.tag.xml', 'entity.other.attribute-name.namespace.xml']

  it "tokenizes attribute-name.localname contains period", ->
    lines = grammar.tokenizeLines """
      <el attr.name="attrValue">
      </el>
    """
    expect(lines[0][3]).toEqual value: 'attr.name', scopes: ['text.xml', 'meta.tag.xml', 'entity.other.attribute-name.localname.xml']

  it "tokenizes attribute-name.localname contains colon", ->
    lines = grammar.tokenizeLines """
      <el namespace:attr:name="attrValue">
      </el>
    """
    expect(lines[0][5]).toEqual value: 'attr:name', scopes: ['text.xml', 'meta.tag.xml', 'entity.other.attribute-name.localname.xml']

  it "tokenizes attribute-name.localname contains East-Asian Kanji", ->
    lines = grammar.tokenizeLines """
      <el 属性名="attrValue">
      </el>
    """
    expect(lines[0][3]).toEqual value: '属性名', scopes: ['text.xml', 'meta.tag.xml', 'entity.other.attribute-name.localname.xml']
