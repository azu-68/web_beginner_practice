 # webrick.rb
require 'webrick'
require "erb" 

server = WEBrick::HTTPServer.new({ 
  :DocumentRoot => './',
  :BindAddress => '127.0.0.1',
  :Port => 8000
})

#Webサーバを立ち上げてWebの仕組みを知る（動的ページ編）
time = Time.now

server.mount_proc("/time") do |req, res|
  # レスポンス内容を出力
  body = "<html><body><p>#{time}</p></body></html>"
  res.status = 200
  res['Content-Type'] = 'text/html'
  res.body = body
end

#Webサーバを立ち上げてWebの仕組みを知る（フォーム編）
server.mount_proc("/form_post") do |req, res|
  name = req.query['user_name']
  age = req.query['user_age']
  body = "<html><head>\n"
  body +="<meta charset='utf-8'></head>\n"         
  #body +="<body><p>クエリパラメータは" +"#{req.query}" +"です</p>" +"<br>\n"      
  body +="<body>クエリパラメータは" + "#{req.query}" + "です<br>\n"          
  body +="こんにちは" + "#{name}" + "さん。あなたの年齢は" + "#{age}" + "ですね\n"                  
        
  body += "</body></html>\n"
  res.status = 200
  res['Content-Type'] = 'text/html'
  res.body = body
end

#Webサーバを立ち上げてWebの仕組みを知る（動的ページ erb 編）
WEBrick::HTTPServlet::FileHandler.add_handler("erb", WEBrick::HTTPServlet::ERBHandler)
server.config[:MimeTypes]["erb"] = "text/html"

server.mount_proc("/hello") do |req, res|
  template = ERB.new( File.read('hello.erb') )
  @time = Time.now
  res.body << template.result( binding )
end

# Webサーバを立ち上げてWebの仕組みを知る（総集編）
foods = [
  { id: 1, name: "りんご", category: "fruits" },
  { id: 2, name: "バナナ", category: "fruits" },
  { id: 3, name: "いちご", category: "fruits" },
  { id: 4, name: "トマト", category: "vegetables" },
  { id: 5, name: "キャベツ", category: "vegetables" },
  { id: 6, name: "レタス", category: "vegetables" },
]

server.mount_proc("/foods") do |req, res|
  template = ERB.new( File.read('./foods/index.erb') )
  
  params = req.query['foods-select']
  
  if params ==  'all'

      @foods = foods.to_a
   
  elsif params ==  'fruits'
    @foods =  foods.first(3)   
  elsif params ==  'vegetables'
    @foods = foods.last(3)
  end
   

  res.body << template.result( binding )
end

trap(:INT){
    server.shutdown
}

server.start
