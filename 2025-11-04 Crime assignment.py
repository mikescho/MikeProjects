import marimo

__generated_with = "0.21.1"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    import polars as pl
    import folium
    from folium.plugins import HeatMap

    return HeatMap, folium, mo, pl


@app.cell
def _(mo):
    mo.md(r"""
    You may use any and all AI tools for this assignment. You may NOT collaborate with any other human.
    """)
    return


@app.cell
def _(mo):
    mo.md(r"""
    ## Task 1: Read the Data
    Use the chicago_crime_2001_2025.parquet file.
    """)
    return


@app.cell
def _(pl):
    df = pl.read_parquet("chicago_crime_2001_2025.parquet")
    df.head()
    return (df,)


@app.cell
def _(mo):
    mo.md(r"""
    ## Task 2: Prep the Data
    Perform Necessary Modifications for the data set. Convert data types, add columns required for analysis
    """)
    return


@app.cell
def _(df, pl):
    df1 = df.with_columns(pl.col("Date").str.to_datetime("%m/%d/%Y %I:%M:%S %p").alias("date_fixed")

    )

    df1.head()


    df2 = df1.with_columns(pl.col("date_fixed").dt.year().alias("year"))

    df2.head()
    return (df2,)


@app.cell
def _(mo):
    mo.md(r"""
    ## Task 3: Most Violent Districts
    List the Top 5 districts with the most Violent Crimes in 2024

    Add a markdown cell explaining which crimes you chose as violent and why.
    """)
    return


@app.cell
def _(df2):
    df2["Primary Type"].unique()
    return


@app.cell
def _():
    violence = {"DOMESTIC VIOLENCE": 1, "ARSON":1,"CRIMINAL SEXUAL ASSAULT":1,"CRIM SEXUAL ASSAULT":1,"KIDNAPPING":1,"ASSAULT":1,"HOMICIDE":1,"BURGLARY":1,"BATTERY":1,"THEFT":1,"ROBBERY":1,"CRIMINAL DAMAGE":1}
    return (violence,)


@app.cell
def _(mo):
    mo.md(r"""
    ## I went through the list of unique crime primary types and tried to identify the ones that I believed to cause harm to another person physically or threaten to do so. While this list may not be complete, I tried to do so in line with the FBI's Uniform Crime Reporting standards.
    """)
    return


@app.cell
def _(df2, pl, violence):
    df3 = df2.with_columns(pl.col("Primary Type").replace_strict(violence,default=0).alias("violent_indicator"))
    df3.head()

    violent_crimes_24 = df3.filter((pl.col("violent_indicator")==1)&(pl.col("year")==2024))
    return df3, violent_crimes_24


@app.cell
def _(pl, violent_crimes_24):
    violent_crimes_24.group_by("District").agg(pl.col("ID").n_unique().alias("violent_crimes")).sort("violent_crimes",descending=True).head(5)
    return


@app.cell
def _(mo):
    mo.md(r"""
    ## Task 4: Breakdown by Crime Type
    Provide the Same list as above, but include a breakdown of crime type
    """)
    return


@app.cell
def _(pl, violent_crimes_24):
    cb = violent_crimes_24.pivot(values="ID",index="District",on="Primary Type",aggregate_function="len")

    cb1 = cb.with_columns(pl.sum_horizontal(pl.exclude("District")).alias("total")).sort("total",descending=True).head(5)

    print(cb1)
    return


@app.cell
def _(mo):
    mo.md(r"""
    ## Task 5: Murder Beats
    Create a polars dataframe showing the top 10 beats by most homicides. Include the District, Community Area, and Homicide count as columns. Sort by homicide count from most to least.
    """)
    return


@app.cell
def _(df3, pl):
    homs = df3.filter(pl.col("Primary Type")=="HOMICIDE")


    homs_group = homs.group_by(["Beat","District","Community Area"]).agg(pl.col("ID").n_unique().alias("homicide_ct")).sort("homicide_ct",descending=True).head(10)

    print(homs_group)
    return


@app.cell
def _(mo):
    mo.md(r"""
    Bonus Task 6: Create a heat map of the areas in Chicago with the highest murder rate
    """)
    return


@app.cell
def _(pl):
    pops = pl.read_excel("chicago_populations.xlsx")
    pops
    return (pops,)


@app.cell
def _(df3, pl):
    murders = df3.filter((pl.col("Primary Type")=="HOMICIDE")).drop_nulls()


    len(murders)
    return (murders,)


@app.cell
def _(murders, pl):
    group = murders.group_by("Community Area").agg([pl.col("ID").n_unique().alias("murder_ct"),pl.col("Longitude").mean().alias("avg_long"),pl.col("Latitude").mean().alias("avg_lat")])
    group
    return (group,)


@app.cell
def _(group, pops):
    joined = group.join(pops,how="left",left_on = "Community Area",right_on="Number")
    return (joined,)


@app.cell
def _(joined):
    joined
    return


@app.cell
def _(joined, pl):
    joined1 = joined.with_columns(

    ((pl.col("murder_ct") / pl.col("Population"))*100000).alias("murder_rate")

    )
    return (joined1,)


@app.cell
def _(joined1):
    heat_data = joined1.select(["avg_lat","avg_long","murder_rate"]).to_numpy().tolist()
    return (heat_data,)


@app.cell
def _(folium):
    m = folium.Map(location=[41.8781,-87.6298],zoom_start=11,tiles="cartodb positron")
    return (m,)


@app.cell
def _(HeatMap, heat_data, m):
    HeatMap(data=heat_data,radius=30,blur=35,min_opacity=.4,max_zoom=1).add_to(m)
    return


@app.cell
def _(m):
    m.save("chicago_crime_heatmap.html")
    return


@app.cell
def _(m):
    m
    return


if __name__ == "__main__":
    app.run()
