# https://rich.readthedocs.io/en/stable/
from rich.console import Console
from rich.table import Table
from rich.align import Align
from rich.text import Text

console = Console(
            force_terminal=True,
            width=None
            )

def logo():
    BANNER = [
    r" _____           _ _",
    r"|  __ \         | | |",
    r"| |__) |__ _  __| | |__   ___",
    r"|  _  // _` |/ _` | '_ \ / _ "+"\\",
    r"| | \ \ (_| | (_| | | | |  __/",
    r"|_|  \_\__,_|\__,_|_| |_|\___|"+" •••",
    "\n"
    ]


    banner= Text("\n".join(BANNER),style="bold magenta")
    console.print(Align.center(banner))
def banner():
    logo()
    table = Table()
    table.title="🚀 DEVELOPER INFO"
    table.show_lines = True
    table.title_style="bold underline yellow on black"

    table.add_column("PLATFORM", justify="center", style="cyan", no_wrap=True)
    table.add_column("USERNAME / URL", justify="left",style="magenta")

    table.add_row("GITHUB",
    "Akhil-Biswas")
    table.add_row("GITLAB",
    "Akhil-Biswas")
    table.add_row("LINKEDIN",
    "akhilbiswas-radhe")
    table.add_row("WEBSITE", "akhil-biswas.netlify.app")

#    console.print(table)
    console.print(Align.center(table))

banner()