require 'spec_helper'

describe Koti::BootLoader do
  let(:conf) { File.expand_path(File.join(File.dirname(__FILE__), 'support/test.yml')) }
  let(:instance) { described_class.new({}, [conf], 'development') }

  describe 'メソッド' do
    describe '#initialize(target, configurations = [], environment = nil)' do
      it '@target, @environment, @configurationsに引数から値を生成しアサインする' do
        target = {}
        confi = [conf]
        env = 'development'
        i = described_class.new(target, confi, env)

        expect(i.instance_variable_get(:@target)).not_to eq nil
        expect(i.instance_variable_get(:@environment)).not_to eq nil
        expect(i.instance_variable_get(:@configurations)).not_to eq nil
      end
    end

    describe '#load(configurations)' do
      it 'configurationsのすべての要素をconfにenvironmentと一緒に送る' do
        configs = [1, 2, 3]
        env = instance.environment

        configs.each do |cfg|
          expect(instance).to receive(:conf).with(cfg, env)
        end

        instance.load(configs)
      end
    end

    describe '#conf(cfg, env)' do
      it 'YAMLファイルcfgをHash化してトップレベルにenvと一致するキーがある場合トップレベルにマージして返す' do
        result = instance.conf(conf, 'test')
        expect(result['hoge']).to eq('fuga')
        expect(result['piyo']).to eq('moge')
      end
    end

    describe '#invoke!' do
      it 'configurationsのすべての要素をsetに送る' do
        instance.configurations = [1, 2, 3]
        expect(instance).to receive(:set).with(1).exactly(1).times
        expect(instance).to receive(:set).with(2).exactly(1).times
        expect(instance).to receive(:set).with(3).exactly(1).times
        instance.invoke!
      end
    end

    describe '#set(source)' do
      it 'targetの[]=に引数sourceをkey-valueを渡す, valueがHashの場合はスキップする' do
        target = instance.target

        expect(target).to receive(:[]=).with(:hoge, 'fuga').exactly(1).times
        expect(target).to receive(:[]=).with(:fuga, 'piyo').exactly(1).times

        instance.set(hoge: 'fuga', fuga: 'piyo', piyo: { moga: 'hoge' })
      end
    end
  end
end

describe Koti::BootLoader::Config do
  let(:path) { File.expand_path(File.join(File.dirname(__FILE__), 'support/test.yml')) }
  let(:instance) { described_class.new(path, :test) }
  describe 'メソッド' do
    describe '#initialize(file, environment)' do
      it 'check!にfileを送る' do
        expect_any_instance_of(described_class).to receive(:check!).with(path.to_s)
        described_class.new(path, 'test')
      end

      it '@config, @enviromentに引数から生成される値がアサインされる' do
        instance = described_class.new(path, 'test')

        expect(instance.instance_variable_get(:@config)).not_to eq nil
        expect(instance.instance_variable_get(:@environment)).not_to eq nil
      end
    end

    describe '#check!(conf)' do
      it '引数confに渡されたパスの文字列にファイルが存在しなければErrno::ENOENTをあげる' do
        expect(File.exist?('/tmp/blblb.lbll')).to eq false
        expect { instance.check!('/tmp/blblb.lbll') }.to raise_error Errno::ENOENT

        expect(File.exist?(path.to_s)).to eq true
        expect { instance.check!(path.to_s) }.not_to raise_error
      end
    end

    describe '#source' do
      it 'configを複製してenviromentで表されるトップレベルのキーがあればトップレベルにマージして返す' do
        mock = {
          hoge: 'hoge',
          fuga: 'fuga',
          development: {
            piyo: 'piyo-d'
          },
          test: {
            piyo: 'piyo-t'
          }
        }
        allow(instance).to receive(:config).and_return(mock)
        expect(instance.source[:hoge]).to eq 'hoge'
        expect(instance.source[:fuga]).to eq 'fuga'
        expect(instance.source[:piyo]).to eq 'piyo-t'
      end
    end
  end
end

describe Koti do
  it 'has a version number' do
    expect(Koti::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(true).to eq(true)
  end
end
