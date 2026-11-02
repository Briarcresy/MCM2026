# 火箭运输
&emsp;&emsp;在此问题的讨论上我们查阅了多篇相关文献，建立了一个预测2050年通过火箭运输物资单次成本和一年内单个火箭发射站发射频率的数学模型$\ce{^{[1][2]}}$。  
&emsp;&emsp;这些文献的研究成果都采用了“莱特定律”的思想，并且提出了一个关键假设，也是我们这个公式的核心，即：每当累积产量翻倍或者实验次数增加，单位成本会以一个固定的百分比下降。该模型的表达式为：
$$C(t) = C_0 (1 - α) ^ {N(t)}$$
---
# 以下有修改   
其中各变量与参数的含义见下表

| 参数符号      | 含义       |
| ----------- | ----------- |
|t|公元年份减去2019年的数值（因为Space X首艘星舰于2019年试飞）|
| C(t)      | 到第t年单次运输任务的成本       |
|T(t)|到第t年单次运输任务的时间|
| $\ce{C_0}$   | 马斯克星舰飞船首次发射的成本        |
| $\ce{T_0}$   | 模拟得到的初始发射间隔        |
|α|学习率|
|N(t)|到第t年已完成的任务数量|

---

&emsp;&emsp;在确定成本函数相关参数时，我们收集了网络上有关的信息并进行了合理的选定。  
（1） 初始造价$\ce{C_0}$  
&emsp;&emsp;为了确定初始成本$\ce{C_0}$，我们通过space X官网，以及Internatioinal Space Elevator Consortium（ISEC）的报道，Space X的首艘货运龙飞船造价约为4.5亿美元，因此在经过查阅资料和评估后，我们取一个相对可靠的值作为预测的$\ce{C_0}$，即$\ce{C_0 = 44940.9}$（百万美元）$\ce{^{[3][4]}}$。  
（2） 学习率α  
&emsp;&emsp;我们考虑到由于飞船技术的学习率会相对较高（大约在15%~20%左右），而燃料、人工、养护等方面的学习率会相对较低（大约在5%~10%左右），为了方便计算和处理，我们最终取α=15%作为我们的初期学习率。但是我们也需要明确，在发展后期由于任务次数的增多，单次任务所带来的学习收益会降低，所以我们将α取成一个相对较小的数，虽然在宏观上效果不如将α设为一个与t有关的函数准确，但是最终效果和计算量上会更加的可观。最终，在查阅资料后我们取α = 3.7139%$\ce{^{[5]}}$。   
（3） 实验次数函数$\ce{N(t)}$  
&emsp;&emsp;为了确定实验次数函数，我们调查了Space X官网上公布的星舰实验次数，并进行了拟合预测。   
&emsp;&emsp;首先，在最初时实验次数为0因为此技术在2019年时还未出现；其次在未来每年内的发射计划将会趋向于一个常数，也就是总的发射量的增长趋势会趋向于kt；除此之外，在2019年后的那段时间内整体增长速度会较快，因为技术迎来了爆发。   
&emsp;&emsp;所以，我们最终采取的模板函数为$\ce{N(t)=⌊k·t + m - \frac{n}{t - t_0}⌋}$。最终拟合结果如下：  
​
  $$k = 3.342857$$
  $$m = -0.857143$$
  $$n = 0.000001$$
  $$t_0 = -10.000000$$
  $$N(t)=⌊3.342857t - 0.857143 - \frac{0.000001}{t + 10}⌋$$
  
&emsp;&emsp;而考虑到n的数量级过小，我们最终抛弃了反比例函数项，仅保留前半部分作为最终的实验次数函数。   
&emsp;&emsp;综上所述，我们最终建立的单次火箭发射成本预测模型如下：
$$C(t) = 44940.9 × (1-0.037139)
   ^ {⌊3.342857t-0.857143⌋}$$
$$\\{(unit:Million\,\,USD)}$$  
&emsp;&emsp;  由这个模型，经过我们的估算，在2028年将150吨的物资运送到月球将要大致花费 $\ce{1.486720016  × 10^{10}\approx 1.5×10^{10}}$即150亿美元，这与马斯克在其官网上公布的计划——在2028年做到每吨运往月球的物资成本为1亿美元相符$\ce{^{[4]}}$。   
&emsp;&emsp;我们可以大致算得在2050年时单次的火箭运输任务的总成本为：7321万美元，考虑到理论和实际的偏差以及科技的进步增速，同时为了方便计算，我们便取单次火箭运输任务的总成本在7300万美元。


---
# 以下有修改  
&emsp;&emsp;在解决年发射量的问题时，我们采用了类似的解决方法方法。我们通过文献查找得知，2025年（以美国的弗洛里达州的卡纳维拉尔角航天港为例）单个航天基地的年发射总量为33次，将33次转化为发射间隔大致为11天/次$\ce{^{[6]}}$。再用类似的处理方法并且查找文献，得到相对可靠的$\ce{T_0 = 13.27}$天，α = 0.983%$\ce{^{[5]}}$。最终的拟合函数为：
$$T(t) = 13.27 × (1-0.00983)^{⌊3.342857t - 0.857143 ⌋}$$
&emsp;&emsp;当t=6时，$\ce{T(t)\approx 10.97\approx11}$天，与我们查到的数据相符合。   
&emsp;&emsp;最终再带入t = 51，可得在2050年单个发射基地的单次任务时间约为2.48$\ce{\approx 2.5}$天。   
&emsp;&emsp;综上所述，在2050年时，单次火箭运输任务的时间成本为2.5天/150吨/次，费用成本为7300万美元/150吨/次（为了模型的简洁性我们暂且不考虑货物重量不同带来的成本浮动，即火箭搭载未满150吨时也考虑相同的成本）。   
# 太空电梯
&emsp;&emsp;针对于太空电梯的费用成本，由于目前世界上并未存在成熟的太空电梯技术和应用实例，我们通过查阅大量文献的方式最终敲定了相关数据。   
&emsp;&emsp;太空电梯运输前往月球的费用成本为40万美元/吨$\ce{^{[7]}}$。




---

[1]. Lam, K. C., Lee, D., & Hu, T. (2001). Understanding the effect of the learning-forgetting phenomenon to duration of projects construction. *International Journal of Project Management*, *19*(7), 411–420. https://doi.org/10.1016/S0263-7863(00)00025-9  

[2]. Kim, S., Koo, J., & Yoon, E. S. (2012). Optimization of sustainable energy planning with consideration of uncertainties in learning rates and external cost factors. In *Computer Aided Chemical Engineering* (Vol. 31, pp. 871–875). Elsevier. https://doi.org/10.1016/B978-0-444-54298-4.50161-6  

[3]. Swan, P. (2019, August 18). Myths busted: The real reason launch costs are high and how space access infrastructure can reduce launch costs to LEO [Conference presentation]. International Space Elevator Conference, [Conference Location unknown]. [URL unknown]

[4]. SpaceX. (n.d.). Starship. SpaceX. Retrieved [2026 Jan. $\ce{30_{th}}$], from https://www.spacex.com/vehicles/starship

[5]. Young, W. A., II, Masel, D. T., & Judd, R. P. (2007). A matrix-based methodology for determining a part family’s learning rate. Computers & Industrial Engineering, *53*(4), 803–811. https://doi.org/10.1016/j.cie.2007.08.002

---
# 以下有修改  
[6].Young, W. A., II, Masel, D. T., & Judd, R. P. (2008). A matrix-based methodology for determining a part family’s learning rate. Computers & Industrial Engineering, 54(3), 390–400.
https://doi.org/10.1016/j.cie.2007.08.002

[7].Smitherman, D. V., Jr. (Comp.). (2000). Space elevators: An advanced earth-space infrastructure for the new millennium (NASA/CP—2000–210429). NASA.

