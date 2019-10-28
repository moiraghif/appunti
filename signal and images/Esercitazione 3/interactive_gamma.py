# Dimostrazione interattiva gamma
def gamma_correct(gamma=1.0):
    ax1 = plt.subplot(121)
    ax1.imshow(im**gamma, cmap='gray');

    ax2 = plt.subplot(122)
    xs = np.array(range(0,101))/100.0
    ys = xs**gamma
    ax2.plot([0,1],[0,1],dashes=[1, 1])
    ax2.plot(xs,ys)
    ax2.set_xlim([0,1])
    ax2.set_ylim([0,1])
gamma_slider = widgets.FloatLogSlider(min=-1, max=1, base=10, value=1.0)
widgets.interact(gamma_correct, gamma=gamma_slider)
