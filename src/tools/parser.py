from parsimonious.grammar import Grammar
from parsimonious.nodes import NodeVisitor
import textwrap
from string import Template
import re
import sys

class MarkupParser(NodeVisitor):
    def __init__(self, text):
        grammar = """
             main = meta? ( nix / markup )*
             newline = ~"[\\n\\s]"+

             meta = newline? meta_open meta_content meta_close
             meta_open = "{---"
             meta_content = ((!meta_close (~".+" / ~"\\n"))+)
             meta_close = "---}"

             markup = (!nix ( esc_nix_open / ~"\{{3,}" / ~"."s ))+

             esc_nix_open = "\\{{"
             esc_nix_close = "\\}}"
             nix = nix_open nix_content nix_close
             nix_open  = "{{" !"{"
             nix_content = ( nix / nix_expr )*
             nix_expr = !nix_open !nix_close (esc_nix_close / ~"."s)
             nix_close = "}}" 
         """
        ast = Grammar(grammar).parse(text)
        self.meta   = "";
        self.markup = "";
        self.result = self.visit(ast)
     

    def visit_main(self, node, children):
        return "".join(filter(lambda x: x != None, children))

    def visit_meta(self, node, children):
        self.meta = "".join(filter(lambda x: x != None, children)) 
        return ""

    def visit_newline(self, node, children):
        return node.text

    def visit_meta_open(self, node, children):
        return ""

    def visit_meta_close(self, node, children):
        return ""

    def visit_meta_content(self, node, children):
        return node.text

    def visit_nix(self, node, children):
        return "".join(children)
    
    def visit_nix_open(self, node, children):
        return "${"

    def visit_nix_close(self, node, children):
        return "}"

    def visit_nix_content(self, node, children):
        return "".join(children)

    def visit_nix_expr(self, node, children):
        return node.text.replace("\}}", "}}")

    def visit_markup(self, node, children):
        return node.text.replace("''", "'''").replace("\{{", "{{").replace("${", "''${")

    def generic_visit(self, node, children):
        return "".join(filter(lambda x: x != None, children))

def processNixText (text):
    # escaping intro sep
    text = text.replace("\>>>", ">>>")
    # escaping page sep
    text = text.replace("\<<<", "<<<")
    return text

def toNix (meta, markup):

    intro_match = markup.split("\n>>>\n")
    if len(intro_match) > 1:
      intro = "intro = ''" + processNixText(intro_match[0]) + "'';"    
      content = intro_match[1]
    else:
      intro = "";
      content = intro_match[0]

    pages_match = content.split("\n<<<\n")
    if len(pages_match) > 1:
      pages = "pages = [ ''" + "''\n''".join( map(lambda x: processNixText(x), pages_match )) + "'' ];"    
      content = ""
    else:
      pages = "";
      content = "content = ''" + processNixText(content) + "'';"


    template = Template( textwrap.dedent("""
      env:
      let meta = rec {
      $meta
      }; in
      with env;
      ({
      $meta
      $content
      $intro
      $pages
      } // meta)
    """))

    return template.safe_substitute(
            meta    = processNixText(meta)
          , intro   = intro
          , content = content
          , pages   = pages
    )

text = sys.stdin.read()

m = MarkupParser(text)

print (toNix (m.meta, m.result))
