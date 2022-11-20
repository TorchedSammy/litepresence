# Litepresence
>  Discord rich presence for Lite XL.

Litepresence is a very simple plugin which adds a rich presence for
[Lite XL](https://github.com/lite-xl/lite-xl).

![](https://safe.kashima.moe/drnc71iq7jl6.png)

# Setup
Litepresence uses a single self-contained [Go](https://go.dev) program to send
rich presence data.  

You can download it [here](https://github.com/TorchedSammy/litepresence/releases/latest)
and just extract it to your Lite XL plugins folder. Alternatively, you can
manually compile it with the steps below.

# Compiling
Clone this repo into your plugins folder and then compile the presence program.
Like so:  
```sh
git clone https://github.com/TorchedSammy/litepresence
cd litepresence
go get
go build
```

# License
Litepresence is licensed under [MIT](LICENSE).
