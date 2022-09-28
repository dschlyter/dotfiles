# Jupyter Notebooks

## Styling pandas

https://pandas.pydata.org/pandas-docs/stable/user_guide/style.html

    import pandas as pd
    data = [[1, 2], [3, 4]]

    ret = pd.DataFrame(data, columns=["Foo", "Bar"])


    def make_pretty(styler):
        styler.set_caption("Weather Conditions")
        # styler.format(rain_condition)
        # styler.format_index(lambda v: v.strftime("%A"))
        styler.background_gradient(axis=None, vmin=1, vmax=5, cmap="RdYlGn")
        return styler

    ret.style.pipe(make_pretty)

# See more

Also check out pandas.md