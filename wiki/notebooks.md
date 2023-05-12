# Jupyter Notebooks

# See more

Also check out pandas.md

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

## Widgets

Simple plot with sliders

    import matplotlib.pyplot as plt
    from ipywidgets import interactive

    def plot(m, c):
        xr = range(10)
        yr = [m * x + c for x in xr]
        plt.plot(xr, yr)
        plt.show()

    interactive(plot, m=(-10, 10, 0.5), c=(-5, 5, 0.5))

A more complicated example with input widgets and an updating plot (was a bit tricky)

    import ipywidgets as widgets
    import matplotlib.pyplot as plt
    from IPython.display import display

    hdisplay = display("", display_id=True)

    data = {
        'a': 8,
        'b': 6
    }

    def update_plot():
        a, b = data['a'], data['b']

        # configure plot
        fig,ax = plt.subplots(1,1)
        ax.set_xlabel('X')
        ax.set_ylabel('Y')
        # ax.set_xlim(0,100)
        # ax.set_ylim(0,100)
        # remove the default plot, will use the update method
        plt.close(fig)

        for [percent, color] in [[a, 'blue'], [b, 'red']]:
            xr = range(100)
            y_acc = 1
            yr = []
            exp = 1 + percent / 100
            for x in xr:
                yr.append(y_acc)
                y_acc *= exp
            ax.plot(xr, yr, color)

        hdisplay.update(fig)

    def update_data(k, v):
        old = data[k]
        data[k] = v
        if v != old:
            update_plot()

    def int_input(value, slider_min, slider_max, desc, update_fn):
        text = widgets.IntText(value, description=desc)
        slider = widgets.IntSlider(value, description="", min=slider_min, max=slider_max)
        widgets.jslink((text, 'value'), (slider, 'value'))
        text.observe(lambda v: update_fn(v['new']), 'value')
        slider.observe(lambda v: update_fn(v['new']), 'value')
        return widgets.HBox([text, slider])

    display(int_input(data['a'], 0, 100, "Input A", lambda v: update_data('a', v)))
    display(int_input(data['b'], 0, 100, "Input B", lambda v: update_data('b', v)))
    # The button is mostly just a trick to remind people to unfocus the input text field
    button = widgets.Button(description='Plot', button_style='success')
    display(button)
    button.on_click(lambda e: update_plot)

    update_plot()

More: https://ipywidgets.readthedocs.io/en/latest/examples/Widget%20List.html
