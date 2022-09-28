# Creating a new column

    res['new_col'] = res.apply(lambda row: my_function[row.old_col], axis=1)

# Filter

    data[data['field'] == 'value']

For multiple values:

    data[(data['field'] == 'value') | (data['field'] == 'value2')]

# Pivot

    res.pivot(index='group_name', columns='sub_group', values='hours')

Or use pivot_table for duplicate handling and moar power

    res.pivot_table(index='group_name', columns='sub_group', values='hours', dropna=False, aggfunc=np.sum)

# Sorting columns

Useful if you want the stacked bar chart to be sorted in some particular way.

    colors = {'x': 'red', 'a': 'green'}
    p_sorted = p[sorted(p.columns, key=lambda col: list(colors.keys()).index(col))]

# Plotting

## Bar chart

[docs](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.plot.bar.html)

Stacked bar chart after pivor

    colors = defaultdict(lambda: "white", {"NO": "grey", "UNKNOWN_BOTH": "orange", "UNKNOWN_DIRECT": "#ff0000", "UNKNOWN_INDIRECT": "yellow", "YES": "green"})
    pivoted.plot.bar(stacked=True, color=colors, ylabel='always label your axis')

## Size

Change the plot size

    df.plot(figsize=(24,12), ...)

Or change the default, but global config like this is bad `plt.rcParams['figure.figsize'] = [10, 6]`

# See more

Also check out notebooks.md