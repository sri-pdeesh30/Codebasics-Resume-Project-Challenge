import plotly.graph_objects as go

# =========================================================
# DATA
# =========================================================

nodes = [
    "DMK+ Loss",
    "AIADMK+ Loss",
    "Others / New Voters",

    "Chennai Metro",
    "Kongu",
    "South",
    "North",
    "Delta",
    "Central",

    "TVK Vote Share"
]

sources = [

    # Chennai Metro
    0, 1, 2, 3,

    # Kongu
    0, 1, 2, 4,

    # South
    0, 1, 2, 5,

    # North
    0, 1, 2, 6,

    # Delta
    0, 1, 2, 7,

    # Central
    0, 1, 2, 8
]

targets = [

    # Chennai Metro
    3, 3, 3, 9,

    # Kongu
    4, 4, 4, 9,

    # South
    5, 5, 5, 9,

    # North
    6, 6, 6, 9,

    # Delta
    7, 7, 7, 9,

    # Central
    8, 8, 8, 9
]

values = [

    # Chennai Metro
    22.53, 14.20, 9.90, 46.63,

    # Kongu
    10.71, 16.75, 7.03, 34.49,

    # South
    9.93, 14.23, 9.36, 33.52,

    # North
    17.47, 11.36, 4.23, 33.06,

    # Delta
    14.21, 11.97, 6.69, 32.87,

    # Central
    16.04, 11.74, 3.24, 31.02
]

# =========================================================
# COLORS
# =========================================================

node_colors = [

    "#C62828",   # DMK+ Loss
    "#1565C0",   # AIADMK+ Loss
    "#757575",   # Others

    "#00897B",   # Chennai
    "#43A047",   # Kongu
    "#FB8C00",   # South
    "#5E35B1",   # North
    "#6D4C41",   # Delta
    "#546E7A",   # Central

    "#8E24AA"    # TVK
]

link_colors = []

for s in sources:

    if s == 0:
        link_colors.append("rgba(198,40,40,0.45)")

    elif s == 1:
        link_colors.append("rgba(21,101,192,0.45)")

    elif s == 2:
        link_colors.append("rgba(120,120,120,0.25)")

    else:
        link_colors.append("rgba(142,36,170,0.45)")

# =========================================================
# NODE LABELS
# =========================================================

labels = [

    "<b>DMK+ LOSS</b>",
    "<b>AIADMK+ LOSS</b>",
    "<b>OTHERS / NEW VOTERS</b>",

    "<b>CHENNAI METRO</b>",
    "<b>KONGU</b>",
    "<b>SOUTH</b>",
    "<b>NORTH</b>",
    "<b>DELTA</b>",
    "<b>CENTRAL</b>",

    "<b>TVK VOTE SHARE</b>"
]

# =========================================================
# FIGURE
# =========================================================

fig = go.Figure(go.Sankey(

    arrangement="fixed",

    node=dict(

        pad=35,
        thickness=32,

        line=dict(
            color="rgba(30,30,30,0.6)",
            width=1.2
        ),

        label=labels,

        color=node_colors,

        x=[
            0.02, 0.02, 0.02,
            0.42, 0.42, 0.42, 0.42, 0.42, 0.42,
            0.88
        ],

        y=[
            0.10, 0.42, 0.75,
            0.02, 0.19, 0.36, 0.53, 0.70, 0.87,
            0.42
        ],

        hovertemplate=
        "<b>%{label}</b><extra></extra>"
    ),

    link=dict(

        source=sources,
        target=targets,
        value=values,
        color=link_colors,

        hovertemplate=
        "<b>Vote Shift:</b> %{value:.2f}%<extra></extra>"
    )
))

# =========================================================
# LAYOUT
# =========================================================

fig.update_layout(

    title=dict(

        text=(
            "<span style='font-size:34px'><b>"
            "Where Did TVK's Votes Come From?"
            "</b></span>"

            "<br>"

           
        ),

        x=0.5,
        xanchor="center"
    ),

    font=dict(
        family="Segoe UI Semibold, Arial",
        size=18,
        color="#111"
    ),

    paper_bgcolor="white",
    plot_bgcolor="white",

    width=1600,
    height=900,

    margin=dict(
        l=30,
        r=30,
        t=120,
        b=60
    )
)

# =========================================================
# REGION CALLOUT BOXES
# =========================================================

annotations = [

    dict(
        x=0.60,
        y=0.96,

        text=
        "<b>CHENNAI METRO</b><br>"
        "<span style='font-size:22px'><b>TVK: 46.63%</b></span><br>"
        "Stronger DMK+ erosion"
    ),

    dict(
        x=0.60,
        y=0.79,

        text=
        "<b>KONGU</b><br>"
        "<span style='font-size:22px'><b>TVK: 34.49%</b></span><br>"
        "Stronger AIADMK+ erosion"
    ),

    dict(
        x=0.60,
        y=0.62,

        text=
        "<b>SOUTH</b><br>"
        "<span style='font-size:22px'><b>TVK: 33.52%</b></span><br>"
        "Stronger AIADMK+ erosion"
    ),

    dict(
        x=0.60,
        y=0.45,

        text=
        "<b>NORTH</b><br>"
        "<span style='font-size:22px'><b>TVK: 33.06%</b></span><br>"
        "Stronger DMK+ erosion"
    ),

    dict(
        x=0.60,
        y=0.28,

        text=
        "<b>DELTA</b><br>"
        "<span style='font-size:22px'><b>TVK: 32.87%</b></span><br>"
        "Stronger DMK+ erosion"
    ),

    dict(
        x=0.60,
        y=0.11,

        text=
        "<b>CENTRAL</b><br>"
        "<span style='font-size:22px'><b>TVK: 31.02%</b></span><br>"
        "Stronger DMK+ erosion"
    )
]

for ann in annotations:

    fig.add_annotation(

        x=ann["x"],
        y=ann["y"],

        xref="paper",
        yref="paper",

        text=ann["text"],

        showarrow=False,

        align="left",

        bordercolor="rgba(0,0,0,0.15)",
        borderwidth=1.2,

        borderpad=10,

        bgcolor="rgba(255,255,255,0.96)",

        font=dict(
            family="Segoe UI",
            size=17,
            color="#111"
        )
    )

# =========================================================
# FOOTNOTE INSIGHT
# =========================================================

fig.add_annotation(

    text=(
        "<b>Key Observation:</b> "
        "TVK's strongest consolidation emerged from DMK+ erosion in Chennai Metro, North, Delta and Central regions, "
        "while Kongu and South reflected relatively stronger AIADMK+ erosion."
    ),

    x=0.5,
    y=-0.08,

    xref="paper",
    yref="paper",

    showarrow=False,

    font=dict(
        family="Segoe UI",
        size=16,
        color="#444"
    ),

    align="center"
)

# =========================================================
# SHOW
# =========================================================

fig.show()