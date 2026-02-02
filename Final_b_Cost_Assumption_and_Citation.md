&emsp;&emsp;在此问题的讨论上我们查阅了多篇相关文献，建立了一个预测2050年通过火箭运输物资单次成本的数学模型$\ce{^{[1][2]}}$。  
&emsp;&emsp;这些文献的研究成果都采用了“莱特定律”的思想，并且提出了一个关键假设，也是我们这个公式的核心，即：每当累积产量翻倍或者实验次数增加，单位成本会以一个固定的百分比下降。  
&emsp;&emsp;在确定相关参数时，我们收集了网络上有关的信息并进行了合理的选定。  
（1） 初始造价$\ce{C_0}$  
&emsp;&emsp;为了确定初始成本$\ce{C_0}$，我们通过space X官网，以及Internatioinal Space Elevator Consortium（ISEC）的报道，Space X的首艘货运龙飞船造价约为4.5亿美元$\ce{^{[3][4]}}$。  
（2） 学习率α  
&emsp;&emsp;我们考虑到由于飞船技术的学习率会相对较高（大约在15%~20%左右），而燃料、人工、养护等方面的学习率会相对较低（大约在5%~10%左右），为了方便计算和处理，我们最终取α=15%作为我们的初期学习率。但是我们也需要明确，在发展后期由于任务次数的增多，单次任务所带来的学习收益会降低，所以我们将α设定为与时间t有关的函数，经过文献阅读、拟合和预测，我们最终敲定的学习率函数为α(t) = $\ce{α(t)=−0.14130506527e^{\frac{ln2}{24}t}
 +0.29130506527
^{[5]}}$。  
（3） 实验次数函数$\ce{N(t)}$  
&emsp;&emsp;为了确定实验次数函数，我们调查了Space X官网上公布的星舰实验次数，并进行了拟合预测。   
&emsp;&emsp;首先，在最初时实验次数为0因为此技术在2019年时还未出现；其次在未来每年内的发射计划将会趋向于一个常数，也就是总的发射量的增长趋势会趋向于kt；除此之外，在2019年后的那段时间内整体增长速度会较快，因为技术迎来了爆发。   
&emsp;&emsp;所以，我们最终采取的模板函数为$\ce{N(t)=k·t + m - \frac{n}{t - t_0}}$。最终拟合结果如下：  
​
  $$k = 3.342857$$
  $$m = -0.857143$$
  $$n = 0.000001$$
  $$t_0 = -10.000000$$
  $$N(t)=3.342857t - 0.857143 - \frac{0.000001}{t + 10}$$
  
&emsp;&emsp;而考虑到n的数量级过小，我们最终抛弃了反比例函数项，仅保留前半部分作为最终的实验次数函数。   
&emsp;&emsp;综上所述，我们最终建立的单次火箭发射成本预测模型如下：
$$C(t) = 150 × (0.70869493473 + 0.14130506527e^{\frac{ln2}{24}t}
  ) ^ {3.342857t-0.857143}$$
$$\\{(unit:Million\,\,USD)}$$  
&emsp;&emsp;  由这个模型，经过我们的估算，我们可以大致算得在2050年时单次的火箭运输任务的总成本为：7499.953125万美元。为了运算方便，后续论文中单次火箭运输任务的总成本将按7500万美元计算。
   
   


---

[1]. Lam, K. C., Lee, D., & Hu, T. (2001). Understanding the effect of the learning-forgetting phenomenon to duration of projects construction. *International Journal of Project Management*, *19*(7), 411–420. https://doi.org/10.1016/S0263-7863(00)00025-9  

[2]. Kim, S., Koo, J., & Yoon, E. S. (2012). Optimization of sustainable energy planning with consideration of uncertainties in learning rates and external cost factors. In *Computer Aided Chemical Engineering* (Vol. 31, pp. 871–875). Elsevier. https://doi.org/10.1016/B978-0-444-54298-4.50161-6  

[3]. Swan, P. (2019, August 18). Myths busted: The real reason launch costs are high and how space access infrastructure can reduce launch costs to LEO [Conference presentation]. International Space Elevator Conference, [Conference Location unknown]. [URL unknown]

[4]. SpaceX. (n.d.). Starship. SpaceX. Retrieved [2026 Jan. $\ce{30_{th}}$], from https://www.spacex.com/vehicles/starship

[5]. Young, W. A., II, Masel, D. T., & Judd, R. P. (2007). A matrix-based methodology for determining a part family’s learning rate. Computers & Industrial Engineering, *53*(4), 803–811. https://doi.org/10.1016/j.cie.2007.08.002
