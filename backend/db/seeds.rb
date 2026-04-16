puts "== 議員シードデータを投入中..."

politicians_data = [
  {
    name: "岸田文雄", name_kana: "きしだふみお",
    party: "自民党", chamber: "衆院", constituency: "広島1区",
    twitter_handle: "fumio_kishida",
    homepage_url: "https://example.com/kishida"
  },
  {
    name: "泉健太", name_kana: "いずみけんた",
    party: "立憲民主党", chamber: "衆院", constituency: "京都3区",
    twitter_handle: "kenta_izumi",
    homepage_url: "https://example.com/izumi"
  },
  {
    name: "山口那津男", name_kana: "やまぐちなつお",
    party: "公明党", chamber: "参院", constituency: "比例区",
    twitter_handle: "natsuo_yamaguchi",
    homepage_url: "https://example.com/yamaguchi"
  },
  {
    name: "馬場伸幸", name_kana: "ばばのぶゆき",
    party: "日本維新の会", chamber: "衆院", constituency: "大阪17区",
    twitter_handle: "baba_nobuyuki",
    homepage_url: "https://example.com/baba"
  },
  {
    name: "玉木雄一郎", name_kana: "たまきゆういちろう",
    party: "国民民主党", chamber: "衆院", constituency: "香川2区",
    twitter_handle: "tamaki_yuichiro",
    homepage_url: "https://example.com/tamaki"
  },
  {
    name: "田村智子", name_kana: "たむらともこ",
    party: "共産党", chamber: "参院", constituency: "比例区",
    twitter_handle: "tamura_tomoko",
    homepage_url: "https://example.com/tamura"
  },
  {
    name: "山本太郎", name_kana: "やまもとたろう",
    party: "れいわ新選組", chamber: "参院", constituency: "比例区",
    twitter_handle: "yamamototaro0",
    homepage_url: "https://example.com/yamamoto"
  }
]

politicians_data.each do |data|
  politician = Politician.find_or_initialize_by(name: data[:name])
  politician.assign_attributes(data)
  politician.save!
  puts "  #{politician.persisted? ? "更新" : "作成"}: #{data[:name]} (#{data[:party]}/#{data[:chamber]})"
end

puts "\n== 活動シードデータを投入中..."

# キーは議員名、値は活動の配列
activities_data = {
  "岸田文雄" => [
    {
      activity_type: "speech",
      description: "衆院本会議にて令和6年度予算案について所信表明を行った。物価高対策と賃上げ促進を重点政策として強調。",
      occurred_at: 2.days.ago
    },
    {
      activity_type: "committee",
      description: "予算委員会に出席。マイナンバーカード普及施策の見直しを約束した。",
      occurred_at: 5.days.ago
    },
    {
      activity_type: "sns",
      description: "「本日、G7広島サミットの成果について改めて報告します」とXに投稿。",
      occurred_at: 1.day.ago
    },
    {
      activity_type: "vote",
      description: "経済安全保障推進法改正案に賛成票を投じた。衆院本会議にて可決。",
      occurred_at: 7.days.ago
    }
  ],
  "泉健太" => [
    {
      activity_type: "speech",
      description: "衆院予算委員会にて政府の物価対策を批判。「給付金より恒久的な政策が必要」と訴えた。",
      occurred_at: 3.days.ago
    },
    {
      activity_type: "sns",
      description: "「立憲民主党は国民の声を国会に届けます。皆さんの意見をぜひお聞かせください」とSNSに投稿。",
      occurred_at: 4.hours.ago
    },
    {
      activity_type: "committee",
      description: "内閣委員会にて行政のデジタル化の地方格差について質問。総務大臣に具体策を求めた。",
      occurred_at: 6.days.ago
    }
  ],
  "山口那津男" => [
    {
      activity_type: "speech",
      description: "参院本会議にて子育て支援拡充法案について賛成討論を行った。「異次元の少子化対策を実現する」と主張。",
      occurred_at: 1.day.ago
    },
    {
      activity_type: "committee",
      description: "文教科学委員会にてGIGAスクール構想の進捗状況について質問。デジタル教科書の全国展開を求めた。",
      occurred_at: 4.days.ago
    },
    {
      activity_type: "sns",
      description: "公明党の防災・減災対策の取り組みについてSNSで報告。能登半島地震被災地への支援状況を紹介。",
      occurred_at: 2.days.ago
    }
  ],
  "馬場伸幸" => [
    {
      activity_type: "speech",
      description: "衆院本会議にて道州制導入の必要性を訴えた。「大阪の成功モデルを全国へ」と強調。",
      occurred_at: 2.days.ago
    },
    {
      activity_type: "committee",
      description: "地方創生特別委員会に出席。地方分権改革の加速を求め、政府の取り組みを批判した。",
      occurred_at: 8.days.ago
    },
    {
      activity_type: "sns",
      description: "「大阪・関西万博の準備状況を視察しました。世界に誇れるイベントにしていきます」とXに投稿。",
      occurred_at: 12.hours.ago
    }
  ],
  "玉木雄一郎" => [
    {
      activity_type: "speech",
      description: "衆院財務金融委員会にて日銀の金融政策について質問。「円安是正のため金利正常化を急ぐべき」と主張。",
      occurred_at: 1.day.ago
    },
    {
      activity_type: "sns",
      description: "「手取りを増やす政策を実現します。103万円の壁を打ち破ります」とXに投稿。多数のリアクションを獲得。",
      occurred_at: 3.hours.ago
    },
    {
      activity_type: "vote",
      description: "所得税法改正案（基礎控除引き上げ）に賛成票を投じた。",
      occurred_at: 5.days.ago
    }
  ],
  "田村智子" => [
    {
      activity_type: "speech",
      description: "参院予算委員会にて防衛費増額に反対する立場から質問。「社会保障を削ってまで軍拡は許されない」と主張。",
      occurred_at: 3.days.ago
    },
    {
      activity_type: "committee",
      description: "厚生労働委員会にて非正規雇用労働者の待遇改善について質問。同一労働同一賃金の徹底を求めた。",
      occurred_at: 6.days.ago
    },
    {
      activity_type: "sns",
      description: "「物価高から国民の暮らしを守る！共産党の緊急提案をご覧ください」とSNSに投稿。",
      occurred_at: 1.day.ago
    }
  ],
  "山本太郎" => [
    {
      activity_type: "speech",
      description: "参院本会議にてインフレ対応として消費税の一時ゼロ化を改めて訴えた。「今こそ決断の時」と強調。",
      occurred_at: 2.days.ago
    },
    {
      activity_type: "committee",
      description: "財政金融委員会に出席。日銀総裁に対しMMT（現代貨幣理論）の観点から財政拡大の必要性を問いただした。",
      occurred_at: 9.days.ago
    },
    {
      activity_type: "sns",
      description: "街頭演説の様子をYouTubeライブで配信。「消費税廃止なくして経済再生なし」と2時間にわたり訴えた。",
      occurred_at: 6.hours.ago
    },
    {
      activity_type: "other",
      description: "物価高に苦しむ市民との対話集会を新宿で開催。約300名が参加した。",
      occurred_at: 4.days.ago
    }
  ]
}

activities_data.each do |politician_name, activities|
  politician = Politician.find_by!(name: politician_name)

  activities.each do |act|
    # 同じ (politician_id, activity_type, occurred_at の日付) の重複を避ける
    Activity.find_or_create_by!(
      politician: politician,
      activity_type: act[:activity_type],
      occurred_at: act[:occurred_at].beginning_of_hour
    ) do |a|
      a.description = act[:description]
    end

    puts "  #{politician_name}: [#{act[:activity_type]}] #{act[:description].truncate(40)}"
  end
end

puts "\n== 完了: #{Politician.count}名の議員、#{Activity.count}件の活動データ"
