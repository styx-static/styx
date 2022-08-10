import re
import sys
import textwrap
from   string import Template

from parsimonious.grammar import Grammar
from parsimonious.nodes import NodeVisitor


class MarkupParser(NodeVisitor):

    def __init__(self, text):
        grammar = """
             main          = meta? (nix / markup)*
             newline       = ~"[\\n\\s]"+

             meta          = newline? meta_open meta_content meta_close
             meta_open     = "---"
             meta_content  = ((!meta_close (meta_prop / newline))+)
             meta_close    = "---"

             meta_prop     = meta_prop_key meta_prop_sep meta_prop_val
             meta_prop_key = (!meta_prop_sep ~".")+
             meta_prop_sep = ":"
             meta_prop_val = ~"."+

             markup        = (!nix (esc_nix_open / ~"\{{3,}" / ~"."s))+

             esc_nix_open  = "\\{{"
             esc_nix_close = "\\}}"
             nix           = nix_open nix_content nix_close
             nix_open      = "{{" !"{"
             nix_content   = (nix / nix_expr)*
             nix_expr      = !nix_open !nix_close (esc_nix_close / ~"."s)
             nix_close     = "}}" 
         """
        self.meta   = "";
        self.markup = "";
        self.result = self.visit(Grammar(grammar).parse(text))

    def visit_main(self, node, children):
        return "".join(filter(lambda x: x != None, children))

    def visit_newline(self, node, children):
        return node.text

    def visit_meta(self, node, children):
        self.meta = "".join(filter(lambda x: x != None, children)) 
        return ""

    def visit_meta_open(self, node, children):
        return ""

    def visit_meta_content(self, node, children):
        return "".join(children)

    def visit_meta_close(self, node, children):
        return ""

    def visit_meta_prop(self, node, children):
        return "".join(children)

    def visit_meta_prop_key(self, node, children):
        return node.text

    def visit_meta_prop_sep(self, node, children):
        return "="

    def visit_meta_prop_val(self, node, children):
        return node.text + ";"

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

def processNixText(text):
    # escaping page sep
    text = text.replace("\<<<", "<<<")
    return text

def toNix(meta, markup):

    args = {
        'meta':    meta,
        'intro':   "",
        'content': "",
        'pages':   ""
    }

    intro_match = markup.split("\n[more]\n")
    if len(intro_match) > 1:
      args['intro']   = "intro = ''{}'';".format(intro_match[0])
      args['content'] = intro_match[1]
    else:
      args['content'] = intro_match[0]

    pages_match = args['content'].split("\n<<<\n")
    if len(pages_match) > 1:
      args['pages']   = "pages = [ ''{}'' ];".format("''\n''".join(map(lambda x: processNixText(x), pages_match)))
      args['content'] = ""
    else:
      args['content'] = "content = ''{}'';".format(args['content'])

    template = Template(textwrap.dedent("""
      env:
      let meta = rec {
      $meta
      }; in
      with env;
      ({
      $content
      $intro
      $pages
      } // meta)
    """))

    return template.safe_substitute(**args)


m = MarkupParser(sys.stdin.read())
print(toNix (m.meta, m.result))
