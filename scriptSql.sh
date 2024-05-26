import { LightningElement, track , wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecords from '@salesforce/apex/Lookup.getRecords';
import getNotificationScreenData from '@salesforce/apex/IgorController.getNotificationScreenData';
import getNotificationScreenDataEmpty from '@salesforce/apex/IgorController.getNotificationScreenDataEmpty';
import upsertNotification from '@salesforce/apex/IgorController.upsertNotification';
import getWeekBody from '@salesforce/apex/IgorController.getWeekBody';
import currentUserId from '@salesforce/user/Id';
import deleteNotificationRecord from '@salesforce/apex/IgorController.deleteNotificationRecord'
import checkUserRecord from '@salesforce/apex/IgorController.checkUser'
import identificarPerfilRecord from '@salesforce/apex/IgorController.identificarPerfilDeAlocacao'
import toggleSchedule from '@salesforce/apex/IgorController.alternarHorario';
export default class NotificationScreen extends LightningElement {

    @track hoursShowMap = []

    async changeHour(){
        const searchEstagiario = await checkUserRecord()
        if(searchEstagiario.length == 0){
            this.hoursShowMap = [
                {hoursTo: '09:00', hoursFrom: '09:30'},
                {hoursTo: '09:30', hoursFrom: '10:00'},
                {hoursTo: '10:00', hoursFrom: '10:30'},
                {hoursTo: '10:30', hoursFrom: '11:00'},
                {hoursTo: '11:00', hoursFrom: '11:30'},
                {hoursTo: '11:30', hoursFrom: '12:00'},
                {hoursTo: '12:00', hoursFrom: '12:30'},
                {hoursTo: '12:30', hoursFrom: '13:00'},
                {hoursTo: '13:00', hoursFrom: '14:00'},
                {hoursTo: '14:00', hoursFrom: '14:30'},
                {hoursTo: '14:30', hoursFrom: '15:00'},
                {hoursTo: '15:00', hoursFrom: '15:30'},
                {hoursTo: '15:30', hoursFrom: '16:00'},
                {hoursTo: '16:00', hoursFrom: '16:30'},
                {hoursTo: '16:30', hoursFrom: '17:00'},
                {hoursTo: '17:00', hoursFrom: '17:30'},
                {hoursTo: '17:30', hoursFrom: '18:00'}
            ];
        }else {

            this.hoursShowMap = [
                {hoursTo: '09:30', hoursFrom: '10:00'},
                {hoursTo: '10:00', hoursFrom: '10:30'},
                {hoursTo: '10:30', hoursFrom: '11:00'},
                {hoursTo: '11:00', hoursFrom: '11:30'},
                {hoursTo: '11:30', hoursFrom: '12:00'},
                {hoursTo: '12:00', hoursFrom: '12:30'},
                {hoursTo: '12:30', hoursFrom: '13:00'},
                {hoursTo: '13:00', hoursFrom: '13:30'},
                {hoursTo: '13:30', hoursFrom: '14:00'},
                {hoursTo: '14:00', hoursFrom: '14:30'},
                {hoursTo: '14:30', hoursFrom: '15:00'},
                {hoursTo: '15:00', hoursFrom: '15:30'},
                {hoursTo: '15:30', hoursFrom: '16:00'}
    ];
           
        }
    }

    offSetWeek = 0;
    listaProjetos = [];
    @track dayMap = {
        '1': 'Segunda',
        '2': 'Terça',
        '3': 'Quarta',
        '4': 'Quinta',
        '5': 'Sexta'
    };
    

    @track hoursMap = {
        '1': ['09:00', '09:30'],
        '2': ['09:30', '10:00'],
        '3': ['10:00', '10:30'],
        '4': ['10:30', '11:00'],
        '5': ['11:00', '11:30'],
        '6': ['11:30', '12:00'],
        '7': ['12:00', '12:30'],
        '8': ['12:30', '13:00'],
        '9': ['13:00', '14:00'],
        '10': ['14:00', '14:30'],
        '11': ['14:30', '15:00'],
        '12': ['15:00', '15:30'],
        '13': ['15:30', '16:00'],
        '14': ['16:00', '16:30'],
        '15': ['16:30', '17:00'],
        '16': ['17:00', '17:30'],
        '17': ['17:30', '18:00']
    };

    @track projectSearchFieldList = ['Projeto__r.Name'];
	@track projectMoreFieldList = ['Projeto__c', 'Name'];
	@track projectTextOptionList = {title: 'Projeto__r.Name', description: ''};
    @track projectWhereFieldList = ['Funcionario__r.UsuarioSalesforce__c'];
    @track projectOperatorList = ['='];
    @track projectWhereFieldValueList = [];

    @track profileSearchFieldList = ['Projeto__r.Name'];
    @track profileMoreFieldList = ['Projeto__c'];
    @track profileTextOptionList = {title: 'Name', description: ''};
    @track profileWhereFieldList = ['Funcionario__r.UsuarioSalesforce__c'];
    @track profileOperatorList = ['='];
    @track profileWhereFieldValueList = [];

    @track notificationWeekList_line1 = [];
    @track notificationWeekList_line2 = [];
   
    @track notificationWeekList_line3 = [];

    @track notificationWeekList_line4 = [];

    @track notificationWeekList_line5 = [];


    @track notificationHeader = {};

    @track isLoading;
    @track horarioAlterado = false;
    
    
    async connectedCallback() {
        await this.changeHour()

        this.notificationWeekList_line1 = [];
        this.notificationWeekList_line2 = [];
        this.notificationWeekList_line3 = [];
        this.notificationWeekList_line4 = [];
        this.notificationWeekList_line5 = [];
        
        this.isLoading = true;
        this.projectWhereFieldValueList.push(currentUserId);
        
        this.isLoadingAllScreen = true;
        this.notificationWeekList_line1 = await getNotificationScreenDataEmpty({offSetWeek: this.offSetWeek, offSetDayWeek: 1});
        this.notificationWeekList_line2 = await getNotificationScreenDataEmpty({offSetWeek: this.offSetWeek, offSetDayWeek: 2});
        this.notificationWeekList_line3 = await getNotificationScreenDataEmpty({offSetWeek: this.offSetWeek, offSetDayWeek: 3});
        this.notificationWeekList_line4 = await getNotificationScreenDataEmpty({offSetWeek: this.offSetWeek, offSetDayWeek: 4});
        this.notificationWeekList_line5 = await getNotificationScreenDataEmpty({offSetWeek: this.offSetWeek, offSetDayWeek: 5});
        
        this.marcarAlmoco();
        
        this.generateNote()
        this.notificationHeader = await getWeekBody({offSetWeek: this.offSetWeek});
        this.isLoadingAllScreen = false;
    }

    async CheckCargo(){
        const searchEstagiario = await checkUserRecord();
        if(searchEstagiario.length == 0) {
            // let horarioClt = [];
            this.hoursShowMap = [
                    { hoursTo: '09:00', hoursFrom: '09:15' },
                    { hoursTo: '09:15', hoursFrom: '09:30' },
                    { hoursTo: '09:30', hoursFrom: '09:45' },
                    { hoursTo: '09:45', hoursFrom: '10:00' },
                    { hoursTo: '10:00', hoursFrom: '10:15' },
                    { hoursTo: '10:15', hoursFrom: '10:30' },
                    { hoursTo: '10:30', hoursFrom: '10:45' },
                    { hoursTo: '10:45', hoursFrom: '11:00' },
                    { hoursTo: '11:00', hoursFrom: '11:15' },
                    { hoursTo: '11:15', hoursFrom: '11:30' },
                    { hoursTo: '11:30', hoursFrom: '11:45' },
                    { hoursTo: '11:45', hoursFrom: '12:00' },
                    { hoursTo: '12:00', hoursFrom: '12:15' },
                    { hoursTo: '12:15', hoursFrom: '12:30' },
                    { hoursTo: '12:30', hoursFrom: '12:45' },
                    { hoursTo: '12:45', hoursFrom: '13:00' },
                    { hoursTo: '13:00', hoursFrom: '14:00' },
                    { hoursTo: '14:00', hoursFrom: '14:15' },
                    { hoursTo: '14:15', hoursFrom: '14:30' },
                    { hoursTo: '14:30', hoursFrom: '14:45' },
                    { hoursTo: '14:45', hoursFrom: '15:00' },
                    { hoursTo: '15:00', hoursFrom: '15:15' },
                    { hoursTo: '15:15', hoursFrom: '15:30' },
                    { hoursTo: '15:30', hoursFrom: '15:45' },
                    { hoursTo: '15:45', hoursFrom: '16:00' },
                    { hoursTo: '16:00', hoursFrom: '16:15' },
                    { hoursTo: '16:15', hoursFrom: '16:30' },
                    { hoursTo: '16:30', hoursFrom: '16:45' },
                    { hoursTo: '16:45', hoursFrom: '17:00' },
                    { hoursTo: '17:00', hoursFrom: '17:15' },
                    { hoursTo: '17:15', hoursFrom: '17:30' },
                    { hoursTo: '17:30', hoursFrom: '17:45' },
                    { hoursTo: '17:45', hoursFrom: '18:00' }
                ];
                console.log('horario clt ====> ',horarioClt)
        }else{
            // let horarioEstagiario = [];
            this.hoursShowMap = [
                { hoursTo: '09:00', hoursFrom: '09:15' },
                { hoursTo: '09:15', hoursFrom: '09:30' },
                { hoursTo: '09:30', hoursFrom: '09:45' },
                { hoursTo: '09:45', hoursFrom: '10:00' },
                { hoursTo: '10:00', hoursFrom: '10:15' },
                { hoursTo: '10:15', hoursFrom: '10:30' },
                { hoursTo: '10:30', hoursFrom: '10:45' },
                { hoursTo: '10:45', hoursFrom: '11:00' },
                { hoursTo: '11:00', hoursFrom: '11:15' },
                { hoursTo: '11:15', hoursFrom: '11:30' },
                { hoursTo: '11:30', hoursFrom: '11:45' },
                { hoursTo: '11:45', hoursFrom: '12:00' },
                { hoursTo: '12:00', hoursFrom: '12:15' },
                { hoursTo: '12:15', hoursFrom: '12:30' },
                { hoursTo: '12:30', hoursFrom: '12:45' },
                { hoursTo: '12:45', hoursFrom: '13:00' },
                { hoursTo: '13:00', hoursFrom: '14:00' },
                { hoursTo: '14:00', hoursFrom: '14:15' },
                { hoursTo: '14:15', hoursFrom: '14:30' },
                { hoursTo: '14:30', hoursFrom: '14:45' },
                { hoursTo: '14:45', hoursFrom: '15:00' },
                { hoursTo: '15:00', hoursFrom: '15:15' },
                { hoursTo: '15:15', hoursFrom: '15:30' },
                { hoursTo: '15:30', hoursFrom: '15:45' },
                { hoursTo: '15:45', hoursFrom: '16:00' }
            ];
            console.log('horario estagiario ===> ',JSON.stringify(horarioEstagiario));
        }   
    }

    async alternarHorarios() {
        // var msg = 'oi';;
        await deleteNotificationRecord({notificationId: notificationId});
        console.log('teste chamando classe apex ==> ', await toggleSchedule(false));
        console.log('horario alterado ===> ',this.horarioAlterado);
        if (this.horarioAlterado) {
            await this.changeHour();
            // this.hoursShowMap = [
            //     { hoursTo: '09:00', hoursFrom: '09:30' },
            //     { hoursTo: '09:30', hoursFrom: '10:00' },
            //     { hoursTo: '10:00', hoursFrom: '10:30' },
            //     { hoursTo: '10:30', hoursFrom: '11:00' },
            //     { hoursTo: '11:00', hoursFrom: '11:30' },
            //     { hoursTo: '11:30', hoursFrom: '12:00' },
            //     { hoursTo: '12:00', hoursFrom: '12:30' },
            //     { hoursTo: '12:30', hoursFrom: '13:00' },
            //     { hoursTo: '13:00', hoursFrom: '14:00' },
            //     { hoursTo: '14:00', hoursFrom: '14:30' },
            //     { hoursTo: '14:30', hoursFrom: '15:00' },
            //     { hoursTo: '15:00', hoursFrom: '15:30' },
            //     { hoursTo: '15:30', hoursFrom: '16:00' },
            //     { hoursTo: '16:00', hoursFrom: '16:30' },
            //     { hoursTo: '16:30', hoursFrom: '17:00' },
            //     { hoursTo: '17:00', hoursFrom: '17:30' },
            //     { hoursTo: '17:30', hoursFrom: '18:00' }
            // ]
            
            this.notificationWeekList_line1 = await getNotificationScreenDataEmpty({ offSetWeek: this.offSetWeek, offSetDayWeek: 1, qtdCards: 17 });
            this.notificationWeekList_line2 = await getNotificationScreenDataEmpty({ offSetWeek: this.offSetWeek, offSetDayWeek: 2, qtdCards: 17 });
            this.notificationWeekList_line3 = await getNotificationScreenDataEmpty({ offSetWeek: this.offSetWeek, offSetDayWeek: 3, qtdCards: 17 });
            this.notificationWeekList_line4 = await getNotificationScreenDataEmpty({ offSetWeek: this.offSetWeek, offSetDayWeek: 4, qtdCards: 17 });
            this.notificationWeekList_line5 = await getNotificationScreenDataEmpty({ offSetWeek: this.offSetWeek, offSetDayWeek: 5, qtdCards: 17 });
            this.horarioAlterado = false;
        }
        else {
            this.horarioAlterado = true;
            await this.CheckCargo();
            // console.log(this.CheckCargo);

            // console.log('PASSANDO PELO CARD ADD AAAAQUIIII');
            this.notificationWeekList_line1 = await getNotificationScreenDataEmpty({ offSetWeek: this.offSetWeek, offSetDayWeek: 1, qtdCards: 33 });
            this.notificationWeekList_line2 = await getNotificationScreenDataEmpty({ offSetWeek: this.offSetWeek, offSetDayWeek: 2, qtdCards: 33 });
            this.notificationWeekList_line3 = await getNotificationScreenDataEmpty({ offSetWeek: this.offSetWeek, offSetDayWeek: 3, qtdCards: 33 });
            this.notificationWeekList_line4 = await getNotificationScreenDataEmpty({ offSetWeek: this.offSetWeek, offSetDayWeek: 4, qtdCards: 33 });
            this.notificationWeekList_line5 = await getNotificationScreenDataEmpty({ offSetWeek: this.offSetWeek, offSetDayWeek: 5, qtdCards: 33 });
            // console.log('PASSEI PELO CARD ADD AAAAAAAAAAAA');
        }
    }

    get isAllNotificationFilled() {
        return this.notificationWeekList_line1.length == 16 ? true : false;
    }

    projectEditFooter(event){
        let notificationCurrentId = event.target.indexId;
        const card = this.template.querySelector(`.${notificationCurrentId}`);
             
        card.style.backgroundColor = '#F4E33D'
        
    }

    async editFooterColor(event){
        let notificationCurrentId = event.currentTarget.dataset.titleId; 
        let notification;
        var coluna = notificationCurrentId.substring(0,1);
     
     switch (coluna) {
         case 'A':
             notification = this.notificationWeekList_line1.find(notification => notification.id == notificationCurrentId);
             const card = this.template.querySelector(`.${notificationCurrentId}`);
             
            card.style.backgroundColor = '#F4E33D'
            //  notification.isLoading = false; 
                return true;
            case 'B':
                notification = this.notificationWeekList_line2.find(notification => notification.id == notificationCurrentId);
                // notification.isLoading = false;
                const card02 = this.template.querySelector(`.${notificationCurrentId}`);
            card02.style.backgroundColor = '#F4E33D'
                return true;
            case 'C':
                notification = this.notificationWeekList_line3.find(notification => notification.id == notificationCurrentId);
                // notification.isLoading = false;
                const card03 = this.template.querySelector(`.${notificationCurrentId}`);
            card03.style.backgroundColor = '#F4E33D'
                return true;
            case 'D':
                notification = this.notificationWeekList_line4.find(notification => notification.id == notificationCurrentId);
                // notification.isLoading = false;
                const card04 = this.template.querySelector(`.${notificationCurrentId}`);
            card04.style.backgroundColor = '#F4E33D'
                return true;
 
            case 'E':
                notification = this.notificationWeekList_line5.find(notification => notification.id == notificationCurrentId);
                // notification.isLoading = false;
                const card05 = this.template.querySelector(`.${notificationCurrentId}`);
            card05.style.backgroundColor = '#F4E33D'
                return true;
            default:
                return false;         
  }  
    }
    async generateNote() {
        var notificationLine1 = await getNotificationScreenData({ offSetWeek: this.offSetWeek, offSetDayWeek: 1 });
        var notificationLine2 = await getNotificationScreenData({ offSetWeek: this.offSetWeek, offSetDayWeek: 2 });
        var notificationLine3 = await getNotificationScreenData({ offSetWeek: this.offSetWeek, offSetDayWeek: 3 });
        var notificationLine4 = await getNotificationScreenData({ offSetWeek: this.offSetWeek, offSetDayWeek: 4 });
        var notificationLine5 = await getNotificationScreenData({ offSetWeek: this.offSetWeek, offSetDayWeek: 5 });

        const searchEstagiario = await checkUserRecord()
        // console.log('quero ver isso pfv =====>', searchEstagiario);
        var notificationLine24;
        var coluna = "A";
        var linha;
        await notificationLine1.forEach((element, i) => {

            var notificationName = element.title;
            var notificationidSalesforce = element.idSalesforce;
            var notificationProjeto = element.projectId;
            var notificationProfile = element.profileId;
            if(searchEstagiario.length == 1){
                switch(element.hourFrom){
                    case "09:30":
                        linha = "1"
                        break;       
                    case "10:00":
                        linha = "2"
                        break; 
                    case "10:30":
                        linha = "3"
                        break;
                    case "11:00":
                        linha = "4"
                        break;
                    case "11:30":
                        linha = "5"
                        break;
                    case "12:00":
                        linha = "6"
                        break;
                    case "12:30":
                        linha = "7"
                        break;
                    case "13:00":
                        linha = "8"
                        break;
                    case "13:30":
                        linha = "9"
                        break;
                    case "14:00": 
                        linha = "10"
                        break;
                    case "14:30":
                        linha = "11"
                        break;
                    case "15:00":
                        linha = "12"
                        break;
                    case "15:30":
                        linha = "13"
                        break;
                    case "16:00":
                        linha = "14"
                        break;
                        default: break;
                }
            }else {

                switch(element.hourFrom){
                    case "09:00":
                        linha = "1"
                        break;
                    case "09:30":
                        linha = "2"
                        break;       
                    case "10:00":
                        linha = "3"
                        break; 
                    case "10:30":
                        linha = "4"
                        break;
                    case "11:00":
                        linha = "5"
                        break;
                    case "11:30":
                        linha = "6"
                        break;
                    case "12:00":
                        linha = "7"
                        break;
                    case "12:30":
                        linha = "8"
                        break;
                    case "13:00":
                        linha = "9"
                        break;
                    case "14:00": 
                        linha = "10"
                        break;
                    case "14:30":
                        linha = "11"
                        break;
                    case "15:00":
                        linha = "12"
                        break;
                    case "15:30":
                        linha = "13"
                        break;
                    case "16:00":
                        linha = "14"
                        break;
                    case "16:30":
                        linha = "15"
                        break;
                    case "17:00":
                        linha = "16"
                        break;
                    case "17:30":
                        linha = "17";
                        break;
                        default: break;
                }
            }
           
            notificationLine24 = this.notificationWeekList_line1.find(element => element.id === coluna + linha);
            notificationLine24.profileId = notificationProfile;
            notificationLine24.projectId = notificationProjeto;
            notificationLine24.title = notificationName;
            notificationLine24.idSalesforce = notificationidSalesforce;
        });

        coluna = "B"
               // Coluna B
               await notificationLine2.forEach((element, i) => {
                var notificationName = element.title;
                var notificationidSalesforce = element.idSalesforce;
                var notificationProjeto = element.projectId;
                var notificationProfile = element.profileId;
                // linha = converterHorario(element);

                if(searchEstagiario.length == 1){
                    console.log('entrei no if do estagiario ====>');
                    switch(element.hourFrom){
                        case "09:30":
                            linha = "1"
                            break;       
                        case "10:00":
                            linha = "2"
                            break; 
                        case "10:30":
                            linha = "3"
                            break;
                        case "11:00":
                            linha = "4"
                            break;
                        case "11:30":
                            linha = "5"
                            break;
                        case "12:00":
                            linha = "6"
                            break;
                        case "12:30":
                            linha = "7"
                            break;
                        case "13:00":
                            linha = "8"
                            break;
                        case "13:30":
                            linha = "9"
                            break;
                        case "14:00": 
                            linha = "10"
                            break;
                        case "14:30":
                            linha = "11"
                            break;
                        case "15:00":
                            linha = "12"
                            break;
                        case "15:30":
                            linha = "13"
                            break;
                        case "16:00":
                            linha = "14"
                            break;
                            default: break;
                    }
                }else {
                    console.log('entrei no if do funcionario normal ====>');
    
                    switch(element.hourFrom){
                        case "09:00":
                            linha = "1"
                            break;
                        case "09:30":
                            linha = "2"
                            break;       
                        case "10:00":
                            linha = "3"
                            break; 
                        case "10:30":
                            linha = "4"
                            break;
                        case "11:00":
                            linha = "5"
                            break;
                        case "11:30":
                            linha = "6"
                            break;
                        case "12:00":
                            linha = "7"
                            break;
                        case "12:30":
                            linha = "8"
                            break;
                        case "13:00":
                            linha = "9"
                            break;
                        case "14:00": 
                            linha = "10"
                            break;
                        case "14:30":
                            linha = "11"
                            break;
                        case "15:00":
                            linha = "12"
                            break;
                        case "15:30":
                            linha = "13"
                            break;
                        case "16:00":
                            linha = "14"
                            break;
                        case "16:30":
                            linha = "15"
                            break;
                        case "17:00":
                            linha = "16"
                            break;
                        case "17:30":
                            linha = "17";
                            break;
                            default: break;
                    }
                }
                notificationLine24 = this.notificationWeekList_line2.find(element => element.id === coluna + linha);
                notificationLine24.profileId = notificationProfile;
                notificationLine24.projectId = notificationProjeto;
                notificationLine24.idSalesforce = notificationidSalesforce;
                notificationLine24.title = notificationName;
            });

            coluna = "C"
                       // Coluna C
                       await notificationLine3.forEach((element, i) => {
                        var notificationName = element.title;
                        var notificationProjeto = element.projectId;
                        var notificationProfile = element.profileId;
                        var notificationidSalesforce = element.idSalesforce;

                        if(searchEstagiario.length == 1){
                            console.log('entrei no if do estagiario ====>');
                            switch(element.hourFrom){
                                case "09:30":
                                    linha = "1"
                                    break;       
                                case "10:00":
                                    linha = "2"
                                    break; 
                                case "10:30":
                                    linha = "3"
                                    break;
                                case "11:00":
                                    linha = "4"
                                    break;
                                case "11:30":
                                    linha = "5"
                                    break;
                                case "12:00":
                                    linha = "6"
                                    break;
                                case "12:30":
                                    linha = "7"
                                    break;
                                case "13:00":
                                    linha = "8"
                                    break;
                                case "13:30":
                                    linha = "9"
                                    break;
                                case "14:00": 
                                    linha = "10"
                                    break;
                                case "14:30":
                                    linha = "11"
                                    break;
                                case "15:00":
                                    linha = "12"
                                    break;
                                case "15:30":
                                    linha = "13"
                                    break;
                                case "16:00":
                                    linha = "14"
                                    break;
                                    default: break;
                            }
                        }else {
                            console.log('entrei no if do funcionario normal ====>');
            
                            switch(element.hourFrom){
                                case "09:00":
                                    linha = "1"
                                    break;
                                case "09:30":
                                    linha = "2"
                                    break;       
                                case "10:00":
                                    linha = "3"
                                    break; 
                                case "10:30":
                                    linha = "4"
                                    break;
                                case "11:00":
                                    linha = "5"
                                    break;
                                case "11:30":
                                    linha = "6"
                                    break;
                                case "12:00":
                                    linha = "7"
                                    break;
                                case "12:30":
                                    linha = "8"
                                    break;
                                case "13:00":
                                    linha = "9"
                                    break;
                                case "14:00": 
                                    linha = "10"
                                    break;
                                case "14:30":
                                    linha = "11"
                                    break;
                                case "15:00":
                                    linha = "12"
                                    break;
                                case "15:30":
                                    linha = "13"
                                    break;
                                case "16:00":
                                    linha = "14"
                                    break;
                                case "16:30":
                                    linha = "15"
                                    break;
                                case "17:00":
                                    linha = "16"
                                    break;
                                case "17:30":
                                    linha = "17";
                                    break;
                                    default: break;
                            }
                        }
                        
                        notificationLine24 = this.notificationWeekList_line3.find(element => element.id === coluna + linha);
                        notificationLine24.profileId = notificationProfile;
                        notificationLine24.projectId = notificationProjeto;
                        notificationLine24.idSalesforce = notificationidSalesforce;
                        notificationLine24.title = notificationName;

                    });
         

                    coluna = "D"
                    // Coluna D
                    await notificationLine4.forEach((element, i) => {
                        var notificationName = element.title;
                        var notificationProjeto = element.projectId;
                        var notificationProfile = element.profileId;
                        var notificationidSalesforce = element.idSalesforce;

                        if(searchEstagiario.length == 1){
                            console.log('entrei no if do estagiario ====>');
                            switch(element.hourFrom){
                                case "09:30":
                                    linha = "1"
                                    break;       
                                case "10:00":
                                    linha = "2"
                                    break; 
                                case "10:30":
                                    linha = "3"
                                    break;
                                case "11:00":
                                    linha = "4"
                                    break;
                                case "11:30":
                                    linha = "5"
                                    break;
                                case "12:00":
                                    linha = "6"
                                    break;
                                case "12:30":
                                    linha = "7"
                                    break;
                                case "13:00":
                                    linha = "8"
                                    break;
                                case "13:30":
                                    linha = "9"
                                    break;
                                case "14:00": 
                                    linha = "10"
                                    break;
                                case "14:30":
                                    linha = "11"
                                    break;
                                case "15:00":
                                    linha = "12"
                                    break;
                                case "15:30":
                                    linha = "13"
                                    break;
                                case "16:00":
                                    linha = "14"
                                    break;
                                    default: break;
                            }
                        }else {
                            console.log('entrei no if do funcionario normal ====>');
            
                            switch(element.hourFrom){
                                case "09:00":
                                    linha = "1"
                                    break;
                                case "09:30":
                                    linha = "2"
                                    break;       
                                case "10:00":
                                    linha = "3"
                                    break; 
                                case "10:30":
                                    linha = "4"
                                    break;
                                case "11:00":
                                    linha = "5"
                                    break;
                                case "11:30":
                                    linha = "6"
                                    break;
                                case "12:00":
                                    linha = "7"
                                    break;
                                case "12:30":
                                    linha = "8"
                                    break;
                                case "13:00":
                                    linha = "9"
                                    break;
                                case "14:00": 
                                    linha = "10"
                                    break;
                                case "14:30":
                                    linha = "11"
                                    break;
                                case "15:00":
                                    linha = "12"
                                    break;
                                case "15:30":
                                    linha = "13"
                                    break;
                                case "16:00":
                                    linha = "14"
                                    break;
                                case "16:30":
                                    linha = "15"
                                    break;
                                case "17:00":
                                    linha = "16"
                                    break;
                                case "17:30":
                                    linha = "17";
                                    break;
                                    default: break;
                            }
                        }
                        notificationLine24 = this.notificationWeekList_line4.find(element => element.id === coluna + linha);
                        notificationLine24.profileId = notificationProfile;
                        notificationLine24.projectId = notificationProjeto;
                        notificationLine24.idSalesforce = notificationidSalesforce;
                        notificationLine24.title = notificationName;

                    });


                    coluna = "E"
                                      // Coluna E
                                      await notificationLine5.forEach((element, i) => {
                                        var notificationName = element.title;
                                        var notificationProjeto = element.projectId;
                                        var notificationProfile = element.profileId;
                                        var notificationidSalesforce = element.idSalesforce;
                                        // linha = converterHorario(element);

                                        if(searchEstagiario.length == 1){
                                            console.log('entrei no if do estagiario ====>');
                                            switch(element.hourFrom){
                                                case "09:30":
                                                    linha = "1"
                                                    break;       
                                                case "10:00":
                                                    linha = "2"
                                                    break; 
                                                case "10:30":
                                                    linha = "3"
                                                    break;
                                                case "11:00":
                                                    linha = "4"
                                                    break;
                                                case "11:30":
                                                    linha = "5"
                                                    break;
                                                case "12:00":
                                                    linha = "6"
                                                    break;
                                                case "12:30":
                                                    linha = "7"
                                                    break;
                                                case "13:00":
                                                    linha = "8"
                                                    break;
                                                case "13:30":
                                                    linha = "9"
                                                    break;
                                                case "14:00": 
                                                    linha = "10"
                                                    break;
                                                case "14:30":
                                                    linha = "11"
                                                    break;
                                                case "15:00":
                                                    linha = "12"
                                                    break;
                                                case "15:30":
                                                    linha = "13"
                                                    break;
                                                case "16:00":
                                                    linha = "14"
                                                    break;
                                                    default: break;
                                            }
                                        }else {
                                            console.log('entrei no if do funcionario normal ====>');
                            
                                            switch(element.hourFrom){
                                                case "09:00":
                                                    linha = "1"
                                                    break;
                                                case "09:30":
                                                    linha = "2"
                                                    break;       
                                                case "10:00":
                                                    linha = "3"
                                                    break; 
                                                case "10:30":
                                                    linha = "4"
                                                    break;
                                                case "11:00":
                                                    linha = "5"
                                                    break;
                                                case "11:30":
                                                    linha = "6"
                                                    break;
                                                case "12:00":
                                                    linha = "7"
                                                    break;
                                                case "12:30":
                                                    linha = "8"
                                                    break;
                                                case "13:00":
                                                    linha = "9"
                                                    break;
                                                case "14:00": 
                                                    linha = "10"
                                                    break;
                                                case "14:30":
                                                    linha = "11"
                                                    break;
                                                case "15:00":
                                                    linha = "12"
                                                    break;
                                                case "15:30":
                                                    linha = "13"
                                                    break;
                                                case "16:00":
                                                    linha = "14"
                                                    break;
                                                case "16:30":
                                                    linha = "15"
                                                    break;
                                                case "17:00":
                                                    linha = "16"
                                                    break;
                                                case "17:30":
                                                    linha = "17";
                                                    break;
                                                    default: break;
                                            }
                                        }

                                        notificationLine24 = this.notificationWeekList_line5.find(element => element.id === coluna + linha);
  
                                        notificationLine24.profileId = notificationProfile;
                                        notificationLine24.projectId = notificationProjeto;
                                        notificationLine24.idSalesforce = notificationidSalesforce;
                                        notificationLine24.title = notificationName;

                                    });
                                    
    }
     async marcarAlmoco() {
        var notificationLine1 = await getNotificationScreenData({ offSetWeek: this.offSetWeek, offSetDayWeek: 1 });
        var notificationLine2 = await getNotificationScreenData({ offSetWeek: this.offSetWeek, offSetDayWeek: 2 });
        var notificationLine3 = await getNotificationScreenData({ offSetWeek: this.offSetWeek, offSetDayWeek: 3 });
        var notificationLine4 = await getNotificationScreenData({ offSetWeek: this.offSetWeek, offSetDayWeek: 4 });
        var notificationLine5 = await getNotificationScreenData({ offSetWeek: this.offSetWeek, offSetDayWeek: 5 });

        const idPerfil = await identificarPerfilRecord()
    
        var idprojectAlmoco = 'a2089000000368vAAA'
        var titleAlmoco = 'Almoço'
        var idProfileAlmoco = idPerfil[0].Id
        const searchEstagiario = await checkUserRecord()
        if(searchEstagiario.length != 0){
            if (notificationLine1 == '') {
                var notificationName = this.notificationWeekList_line1[7].title = titleAlmoco
                var notificationProjeto = this.notificationWeekList_line1[7].projectId = idprojectAlmoco
                var notificationProfile = this.notificationWeekList_line1[7].profileId = idProfileAlmoco
            }
            if (notificationLine2 == '') {
                var notificationName = this.notificationWeekList_line2[7].title = titleAlmoco
                var notificationProjeto = this.notificationWeekList_line2[7].projectId = idprojectAlmoco
                var notificationProfile = this.notificationWeekList_line2[7].profileId = idProfileAlmoco
            }
            if (notificationLine3 == '') {
                var notificationName = this.notificationWeekList_line3[7].title = titleAlmoco
                var notificationProjeto = this.notificationWeekList_line3[7].projectId = idprojectAlmoco
                var notificationProfile = this.notificationWeekList_line3[7].profileId = idProfileAlmoco
            }
            if (notificationLine4 == '') {
                var notificationName = this.notificationWeekList_line4[7].title = titleAlmoco
                var notificationProjeto = this.notificationWeekList_line4[7].projectId = idprojectAlmoco
                var notificationProfile = this.notificationWeekList_line4[7].profileId = idProfileAlmoco
            }
            if (notificationLine5 == '') {
                var notificationName = this.notificationWeekList_line5[7].title = titleAlmoco
                var notificationProjeto = this.notificationWeekList_line5[7].projectId = idprojectAlmoco
                var notificationProfile = this.notificationWeekList_line5[7].profileId = idProfileAlmoco
            }
        }else {
            if (notificationLine1 == '') {
                var notificationName =  this.notificationWeekList_line1[8].title = titleAlmoco
                var notificationProjeto = this.notificationWeekList_line1[8].projectId = idprojectAlmoco
                var notificationProfile = this.notificationWeekList_line1[8].profileId = idProfileAlmoco
            }
            if (notificationLine2 == '') {
                var notificationName = this.notificationWeekList_line2[8].title = titleAlmoco
                var notificationProjeto = this.notificationWeekList_line2[8].projectId = idprojectAlmoco
                var notificationProfile = this.notificationWeekList_line2[8].profileId = idProfileAlmoco
            }
            if (notificationLine3 == '') {
                var notificationName = this.notificationWeekList_line3[8].title = titleAlmoco
                var notificationProjeto = this.notificationWeekList_line3[8].projectId = idprojectAlmoco
                var notificationProfile = this.notificationWeekList_line3[8].profileId = idProfileAlmoco
            }
            if (notificationLine4 == '') {
                var notificationName = this.notificationWeekList_line4[8].title = titleAlmoco
                var notificationProjeto = this.notificationWeekList_line4[8].projectId = idprojectAlmoco
                var notificationProfile = this.notificationWeekList_line4[8].profileId = idProfileAlmoco
            }
            if (notificationLine5 == '') {
                var notificationName = this.notificationWeekList_line5[8].title = titleAlmoco
                var notificationProjeto = this.notificationWeekList_line5[8].projectId = idprojectAlmoco
                var notificationProfile = this.notificationWeekList_line5[8].profileId = idProfileAlmoco
            }
        }
    }

    async deleteNotification(notification) {
        
        let notificationId = notification.idSalesforce;

        if (notificationId) {
            try {
                await deleteNotificationRecord({notificationId: notificationId});
                const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Apontamento excluído com sucesso!',
                    variant: 'success',
                });
                this.dispatchEvent(event);
                            const card = this.template.querySelector(`.${notification.id}`);

                            card.style.backgroundColor = '#fff'
                    this.isLoading = false;
            } catch (error) {
                console.error('Erro ao excluir a notificação:', error);
                const event = new ShowToastEvent({
                    title: 'Erro',
                    message: 'Não foi possível excluir apontamento',
                    variant: 'error',
                });
                return false;
            }
        } else {
            console.error('Notificação não encontrada.');
            return false;
        }
    }
    async handleClearNotificationCard(event) {
        console.log('dadadad');
            var coluna = event.currentTarget.dataset.id.substring(0,1);
            var linha = event.currentTarget.dataset.id.substring(1,3);
            let notification;
            switch(coluna) {
                case 'A':                  
                notification = this.notificationWeekList_line1.find(element =>  element.id == (coluna + linha));
                    if(notification.projectId != null || notification.title != ''){
                        if (confirm("Você deseja apagar esse registro?") == true){
                            
                            
                            await this.deleteNotification(notification)
                            notification.profileId = null;
                            notification.idSalesforce = null;
                            notification.projectId = null;
                            notification.title = '';
                        }
                    }
                    
                break;
                case 'B':
                    notification = this.notificationWeekList_line2.find(element => element.id == (coluna + linha));
                    if(notification.projectId != null || notification.title != ''){
                        if (confirm("Você deseja apagar esse registro?") == true){
                            await this.deleteNotification(notification)
                            notification.profileId = null;
                            notification.idSalesforce = null;
                            notification.projectId = null;
                            notification.title = '';
                        }
                    }
                break;
                case 'C':
                    notification = this.notificationWeekList_line3.find(element =>  element.id == (coluna + linha));
                    if(notification.projectId != null || notification.title != ''){
                        if (confirm("Você deseja apagar esse registro?") == true){
                            await this.deleteNotification(notification)
                        
                            notification.profileId = null;
                            notification.idSalesforce = null;
                            notification.projectId = null;
                            notification.title = '';
                        }
                    }
                break;
                case 'D':
                    notification = this.notificationWeekList_line4.find(element =>  element.id == (coluna + linha));
                    if(notification.projectId != null || notification.title != ''){
                        if (confirm("Você deseja apagar esse registro?") == true){
                            await this.deleteNotification(notification)
                        
                            notification.profileId = null;
                            notification.idSalesforce = null;
                            notification.projectId = null;
                            notification.title = '';
                        }
                    }
                break;
                case 'E':
                    notification = this.notificationWeekList_line5.find(element =>  element.id == (coluna + linha));
                    if(notification.projectId != null || notification.title != ''){
                        if (confirm("Você deseja apagar esse registro?") == true){
                            await this.deleteNotification(notification)
                        
                            notification.profileId = null;
                            notification.idSalesforce = null;
                            notification.projectId = null;
                            notification.title = '';
                        }
                    }
                break;
                default:
                    break;
            
        }
    }
  

      async handleCloneNotificationToAboveOne(event) {
        var coluna = event.currentTarget.dataset.id.substring(0,1);
        var linha = event.currentTarget.dataset.id.substring(1,3);

        let notification;
        let indexInteger;
        switch(coluna) {

            case 'A':
                indexInteger = Number(linha);
    
                notification = this.notificationWeekList_line1.find(notification => notification.id === event.currentTarget.dataset.id);
    
                this.notificationWeekList_line1[indexInteger].profileId = notification.profileId;
                this.notificationWeekList_line1[indexInteger].projectId = notification.projectId;
                this.notificationWeekList_line1[indexInteger].title = notification.title;
                this.notificationWeekList_line1[indexInteger].isLoading = false;

                if (!this.notificationWeekList_line1[indexInteger] && !this.notificationWeekList_line1[indexInteger].idSalesforce) {

                    this.notificationWeekList_line1[indexInteger].profileId = notification.profileId;
                    this.notificationWeekList_line1[indexInteger].projectId = notification.projectId;
                    this.notificationWeekList_line1[indexInteger].title = notification.title;
                    this.notificationWeekList_line1[indexInteger].isLoading = false;
    
                } else {
                    if(this.notificationWeekList_line1[indexInteger] && this.notificationWeekList_line1[indexInteger].idSalesforce) { 
    
                    const updatedNotification = await this.saveNotification(this.notificationWeekList_line1[indexInteger]);
                    this.notificationWeekList_line1[indexInteger].idSalesforce = updatedNotification.idSalesforce;
                }
                
                this.notificationWeekList_line1[indexInteger].isLoading = false;
            }
                
            break;
            case 'B':
                indexInteger = Number(linha);
                notification = this.notificationWeekList_line2.find(notification => notification.id === event.currentTarget.dataset.id);

                this.notificationWeekList_line2[indexInteger].profileId = notification.profileId;
                this.notificationWeekList_line2[indexInteger].projectId = notification.projectId;
                this.notificationWeekList_line2[indexInteger].title = notification.title;
                this.notificationWeekList_line2[indexInteger].isLoading = false;

                if (!this.notificationWeekList_line2[indexInteger] && !this.notificationWeekList_line2[indexInteger].idSalesforce) {

                    this.notificationWeekList_line2[indexInteger].profileId = notification.profileId;
                    this.notificationWeekList_line2[indexInteger].projectId = notification.projectId;
                    this.notificationWeekList_line2[indexInteger].title = notification.title;
                    this.notificationWeekList_line2[indexInteger].isLoading = false;
    
                } else {
                    if(this.notificationWeekList_line2[indexInteger] && this.notificationWeekList_line2[indexInteger].idSalesforce) { 
    
                    const updatedNotification = await this.saveNotification(this.notificationWeekList_line2[indexInteger]);
                    this.notificationWeekList_line2[indexInteger].idSalesforce = updatedNotification.idSalesforce;
                }
                
                this.notificationWeekList_line2[indexInteger].isLoading = false;
            }
            break;
            case 'C':
                indexInteger = Number(linha);
                notification = this.notificationWeekList_line3.find(notification => notification.id === event.currentTarget.dataset.id);

                this.notificationWeekList_line3[indexInteger].profileId = notification.profileId;
                this.notificationWeekList_line3[indexInteger].projectId = notification.projectId;
                this.notificationWeekList_line3[indexInteger].title = notification.title;
                this.notificationWeekList_line3[indexInteger].isLoading = false;

                if (!this.notificationWeekList_line3[indexInteger] && !this.notificationWeekList_line3[indexInteger].idSalesforce) {

                    this.notificationWeekList_line3[indexInteger].profileId = notification.profileId;
                    this.notificationWeekList_line3[indexInteger].projectId = notification.projectId;
                    this.notificationWeekList_line3[indexInteger].title = notification.title;
                    this.notificationWeekList_line3[indexInteger].isLoading = false;
    
                } else {
                    if(this.notificationWeekList_line3[indexInteger] && this.notificationWeekList_line3[indexInteger].idSalesforce) { 
    
                    const updatedNotification = await this.saveNotification(this.notificationWeekList_line3[indexInteger]);
                    this.notificationWeekList_line3[indexInteger].idSalesforce = updatedNotification.idSalesforce;
                }
                
                this.notificationWeekList_line3[indexInteger].isLoading = false;
            }

            break;
            case 'D':
                indexInteger = Number(linha);
                notification = this.notificationWeekList_line4.find(notification => notification.id === event.currentTarget.dataset.id);
    
                this.notificationWeekList_line4[indexInteger].profileId = notification.profileId;
                this.notificationWeekList_line4[indexInteger].projectId = notification.projectId;
                this.notificationWeekList_line4[indexInteger].title = notification.title;
                this.notificationWeekList_line4[indexInteger].isLoading = false;
                
                if (!this.notificationWeekList_line4[indexInteger] && !this.notificationWeekList_line4[indexInteger].idSalesforce) {

                    this.notificationWeekList_line4[indexInteger].profileId = notification.profileId;
                    this.notificationWeekList_line4[indexInteger].projectId = notification.projectId;
                    this.notificationWeekList_line4[indexInteger].title = notification.title;
                    this.notificationWeekList_line4[indexInteger].isLoading = false;
    
                } else {
                    if(this.notificationWeekList_line4[indexInteger] && this.notificationWeekList_line4[indexInteger].idSalesforce) { 
    
                    const updatedNotification = await this.saveNotification(this.notificationWeekList_line4[indexInteger]);
                    this.notificationWeekList_line4[indexInteger].idSalesforce = updatedNotification.idSalesforce;
                }
                
                this.notificationWeekList_line4[indexInteger].isLoading = false;
            }

            break;
            case 'E':
                indexInteger = Number(linha);
                notification = this.notificationWeekList_line5.find(notification => notification.id === event.currentTarget.dataset.id);
    
                this.notificationWeekList_line5[indexInteger].profileId = notification.profileId;
                this.notificationWeekList_line5[indexInteger].projectId = notification.projectId;
                this.notificationWeekList_line5[indexInteger].title = notification.title;
                this.notificationWeekList_line5[indexInteger].isLoading = false;

                if (!this.notificationWeekList_line5[indexInteger] && !this.notificationWeekList_line5[indexInteger].idSalesforce) {

                    this.notificationWeekList_line5[indexInteger].profileId = notification.profileId;
                    this.notificationWeekList_line5[indexInteger].projectId = notification.projectId;
                    this.notificationWeekList_line5[indexInteger].title = notification.title;
                    this.notificationWeekList_line5[indexInteger].isLoading = false;
    
                } else {
                    if(this.notificationWeekList_line5[indexInteger] && this.notificationWeekList_line5[indexInteger].idSalesforce) { 
    
                    const updatedNotification = await this.saveNotification(this.notificationWeekList_line5[indexInteger]);
                    this.notificationWeekList_line5[indexInteger].idSalesforce = updatedNotification.idSalesforce;
                }
                
                this.notificationWeekList_line5[indexInteger].isLoading = false;
            }
            break;
            default:
                break;
    }    
}

   async handleCloneNotificationToAbove(event) {
    let coluna = event.currentTarget.dataset.id.substring(0,1);
    let linha = event.currentTarget.dataset.id.substring(1,3);

    if (coluna.toString() == 'A'.toString()) {
    let indexInteger = Number(linha) - 1;

    for (let i = 0; i < this.notificationWeekList_line1.length; i++) {
        if (i >= indexInteger) {
            this.notificationWeekList_line1[i].profileId = this.notificationWeekList_line1[indexInteger].profileId;
            this.notificationWeekList_line1[i].projectId = this.notificationWeekList_line1[indexInteger].projectId;
            this.notificationWeekList_line1[i].title = this.notificationWeekList_line1[indexInteger].title;
            this.notificationWeekList_line1[i].isLoading = false;


            const searchEstagiario = await checkUserRecord()
            const idPerfil = await identificarPerfilRecord()
            if(searchEstagiario.length != 0){
                if(i == 8) {
                    var idprojectAlmoco = 'a2089000000368vAAA'
                    var titleAlmoco = 'Almoço'
                    var idProfileAlmoco = idPerfil[0].Id
                    var notificationName = this.notificationWeekList_line1[7].title = titleAlmoco
                    var notificationProjeto = this.notificationWeekList_line1[7].projectId = idprojectAlmoco
                    var notificationProfile = this.notificationWeekList_line1[7].profileId = idProfileAlmoco
                }
            }else {
                if(i == 9) {
                    var idprojectAlmoco = 'a2089000000368vAAA'
                    var titleAlmoco = 'Almoço'
                    var idProfileAlmoco = idPerfil[0].Id
                    var notificationName = this.notificationWeekList_line1[8].title = titleAlmoco
                    var notificationProjeto = this.notificationWeekList_line1[8].projectId = idprojectAlmoco
                    var notificationProfile = this.notificationWeekList_line1[8].profileId = idProfileAlmoco
                }
            }
            
            if (!this.notificationWeekList_line1[indexInteger] && !this.notificationWeekList_line1[i].idSalesforce) {

                this.notificationWeekList_line1[i].profileId = this.notificationWeekList_line1[indexInteger].profileId;
                this.notificationWeekList_line1[i].projectId = this.notificationWeekList_line1[indexInteger].projectId;
                this.notificationWeekList_line1[i].title = this.notificationWeekList_line1[indexInteger].title;
                
                this.notificationWeekList_line1[i].isLoading = false;
            } else {
                if(this.notificationWeekList_line1[i] && this.notificationWeekList_line1[i].idSalesforce) { 

                const updatedNotification = await this.saveNotification(this.notificationWeekList_line1[i]);
                this.notificationWeekList_line1[i].idSalesforce = updatedNotification.idSalesforce;
            }
            this.notificationWeekList_line1[i].isLoading = false;

        }
    }
    }    
    } else if(coluna.toString() == 'B'.toString()) {
        let indexInteger = Number(linha) - 1;

        for (let i = 0; i < this.notificationWeekList_line2.length; i++) {
            if (i >= indexInteger) {
                
                this.notificationWeekList_line2[i].profileId = this.notificationWeekList_line2[indexInteger].profileId;
                this.notificationWeekList_line2[i].projectId = this.notificationWeekList_line2[indexInteger].projectId;
                this.notificationWeekList_line2[i].title = this.notificationWeekList_line2[indexInteger].title;
                this.notificationWeekList_line2[i].isLoading = false;
            

                const searchEstagiario = await checkUserRecord()
            const idPerfil = await identificarPerfilRecord()
            if(searchEstagiario.length != 0){
                if(i == 8) {
                    var idprojectAlmoco = 'a2089000000368vAAA'
                    var titleAlmoco = 'Almoço'
                    var idProfileAlmoco = idPerfil[0].Id
                    var notificationName = this.notificationWeekList_line2[7].title = titleAlmoco
                    var notificationProjeto = this.notificationWeekList_line2[7].projectId = idprojectAlmoco
                    var notificationProfile = this.notificationWeekList_line2[7].profileId = idProfileAlmoco
                }
            }else {
                if(i == 9) {
                    var idprojectAlmoco = 'a2089000000368vAAA'
                    var titleAlmoco = 'Almoço'
                    var idProfileAlmoco = idPerfil[0].Id
                    var notificationName = this.notificationWeekList_line2[8].title = titleAlmoco
                    var notificationProjeto = this.notificationWeekList_line2[8].projectId = idprojectAlmoco
                    var notificationProfile = this.notificationWeekList_line2[8].profileId = idProfileAlmoco
                }
            }
            if (!this.notificationWeekList_line2[indexInteger] && !this.notificationWeekList_line2[i].idSalesforce) {

                this.notificationWeekList_line2[i].profileId = this.notificationWeekList_line2[indexInteger].profileId;
                this.notificationWeekList_line2[i].projectId = this.notificationWeekList_line2[indexInteger].projectId;
                this.notificationWeekList_line2[i].title = this.notificationWeekList_line2[indexInteger].title;
                this.notificationWeekList_line2[i].isLoading = false;

            } else {
                if(this.notificationWeekList_line2[i] && this.notificationWeekList_line2[i].idSalesforce) { 

                const updatedNotification = await this.saveNotification(this.notificationWeekList_line2[i]);
                this.notificationWeekList_line2[i].idSalesforce = updatedNotification.idSalesforce;
            }
            
            this.notificationWeekList_line2[i].isLoading = false;
        }

        }
        }
    } else if(coluna.toString() == 'C'.toString()) {
        let indexInteger = Number(linha) - 1;

        for (var i = 0; i < this.notificationWeekList_line3.length; i++) {

          if(i >= indexInteger) {
              this.notificationWeekList_line3[i].profileId = this.notificationWeekList_line3[indexInteger].profileId;
              this.notificationWeekList_line3[i].projectId = this.notificationWeekList_line3[indexInteger].projectId;
              this.notificationWeekList_line3[i].title = this.notificationWeekList_line3[indexInteger].title;
              this.notificationWeekList_line3[i].isLoading = false;

              const searchEstagiario = await checkUserRecord()
              const idPerfil = await identificarPerfilRecord()
              if(searchEstagiario.length != 0){
                  if(i == 8) {
                      var idprojectAlmoco = 'a2089000000368vAAA'
                      var titleAlmoco = 'Almoço'
                      var idProfileAlmoco = idPerfil[0].Id
                      var notificationName = this.notificationWeekList_line3[7].title = titleAlmoco
                      var notificationProjeto = this.notificationWeekList_line3[7].projectId = idprojectAlmoco
                      var notificationProfile = this.notificationWeekList_line3[7].profileId = idProfileAlmoco
                  }
              }else {
                  if(i == 9) {
                      var idprojectAlmoco = 'a2089000000368vAAA'
                      var titleAlmoco = 'Almoço'
                      var idProfileAlmoco = idPerfil[0].Id
                      var notificationName = this.notificationWeekList_line3[8].title = titleAlmoco
                      var notificationProjeto = this.notificationWeekList_line3[8].projectId = idprojectAlmoco
                      var notificationProfile = this.notificationWeekList_line3[8].profileId = idProfileAlmoco
                  }
              }

              if (!this.notificationWeekList_line3[indexInteger] && !this.notificationWeekList_line3[i].idSalesforce) {

                this.notificationWeekList_line3[i].profileId = this.notificationWeekList_line3[indexInteger].profileId;
                this.notificationWeekList_line3[i].projectId = this.notificationWeekList_line3[indexInteger].projectId;
                this.notificationWeekList_line3[i].title = this.notificationWeekList_line3[indexInteger].title;
                this.notificationWeekList_line3[i].isLoading = false;

            } else {
                if(this.notificationWeekList_line3[i] && this.notificationWeekList_line3[i].idSalesforce) { 

                const updatedNotification = await this.saveNotification(this.notificationWeekList_line3[i]);
                this.notificationWeekList_line3[i].idSalesforce = updatedNotification.idSalesforce;
            }
            
            this.notificationWeekList_line3[i].isLoading = false;
        }

          }
        }
    } else if(coluna.toString() == 'D'.toString()) {
        let indexInteger = Number(linha) - 1;

        for (var i = 0; i < this.notificationWeekList_line4.length; i++) {

          if(i >= indexInteger) {
              this.notificationWeekList_line4[i].profileId = this.notificationWeekList_line4[indexInteger].profileId;
              this.notificationWeekList_line4[i].projectId = this.notificationWeekList_line4[indexInteger].projectId;
              this.notificationWeekList_line4[i].title = this.notificationWeekList_line4[indexInteger].title;
              this.notificationWeekList_line4[i].isLoading = false;

              const searchEstagiario = await checkUserRecord()
              const idPerfil = await identificarPerfilRecord()
              if(searchEstagiario.length != 0){
                  if(i == 8) {
                      var idprojectAlmoco = 'a2089000000368vAAA'
                      var titleAlmoco = 'Almoço'
                      var idProfileAlmoco = idPerfil[0].Id
                      var notificationName = this.notificationWeekList_line4[7].title = titleAlmoco
                      var notificationProjeto = this.notificationWeekList_line4[7].projectId = idprojectAlmoco
                      var notificationProfile = this.notificationWeekList_line4[7].profileId = idProfileAlmoco
                  }
              }else {
                  console.log('entrei aquiii');
                  if(i == 9) {
                      var idprojectAlmoco = 'a2089000000368vAAA'
                      var titleAlmoco = 'Almoço'
                      var idProfileAlmoco = idPerfil[0].Id
                      var notificationName = this.notificationWeekList_line4[8].title = titleAlmoco
                      var notificationProjeto = this.notificationWeekList_line4[8].projectId = idprojectAlmoco
                      var notificationProfile = this.notificationWeekList_line4[8].profileId = idProfileAlmoco
                  }
              }

              if (!this.notificationWeekList_line4[indexInteger] && !this.notificationWeekList_line4[i].idSalesforce) {

                this.notificationWeekList_line4[i].profileId = this.notificationWeekList_line4[indexInteger].profileId;
                this.notificationWeekList_line4[i].projectId = this.notificationWeekList_line4[indexInteger].projectId;
                this.notificationWeekList_line4[i].title = this.notificationWeekList_line4[indexInteger].title;
                this.notificationWeekList_line4[i].isLoading = false;

            } else {
                if(this.notificationWeekList_line4[i] && this.notificationWeekList_line4[i].idSalesforce) { 

                const updatedNotification = await this.saveNotification(this.notificationWeekList_line4[i]);
                this.notificationWeekList_line4[i].idSalesforce = updatedNotification.idSalesforce;
            }
            
            this.notificationWeekList_line4[i].isLoading = false;
        }

          }
        }
    } else if(coluna.toString() == 'E'.toString()) {
        let indexInteger = Number(linha) - 1;

        for (var i = 0; i < this.notificationWeekList_line5.length; i++) {

          if(i >= indexInteger) {
              this.notificationWeekList_line5[i].profileId = this.notificationWeekList_line5[indexInteger].profileId;
              this.notificationWeekList_line5[i].projectId = this.notificationWeekList_line5[indexInteger].projectId;
              this.notificationWeekList_line5[i].title = this.notificationWeekList_line5[indexInteger].title;
              this.notificationWeekList_line5[i].isLoading = false;

              const searchEstagiario = await checkUserRecord()
              const idPerfil = await identificarPerfilRecord()
              if(searchEstagiario.length != 0){
                  if(i == 8) {
                      var idprojectAlmoco = 'a2089000000368vAAA'
                      var titleAlmoco = 'Almoço'
                      var idProfileAlmoco = idPerfil[0].Id
                      var notificationName = this.notificationWeekList_line5[7].title = titleAlmoco
                      var notificationProjeto = this.notificationWeekList_line5[7].projectId = idprojectAlmoco
                      var notificationProfile = this.notificationWeekList_line5[7].profileId = idProfileAlmoco
                  }
              }else {
                  if(i == 9) {
                    
                      var idprojectAlmoco = 'a2089000000368vAAA'
                      var titleAlmoco = 'Almoço'
                      var idProfileAlmoco = idPerfil[0].Id
                      var notificationName = this.notificationWeekList_line5[8].title = titleAlmoco
                      var notificationProjeto = this.notificationWeekList_line5[8].projectId = idprojectAlmoco
                      var notificationProfile = this.notificationWeekList_line5[8].profileId = idProfileAlmoco
                  }
              }

              if (!this.notificationWeekList_line5[indexInteger] && !this.notificationWeekList_line5[i].idSalesforce) {

                this.notificationWeekList_line5[i].profileId = this.notificationWeekList_line5[indexInteger].profileId;
                this.notificationWeekList_line5[i].projectId = this.notificationWeekList_line5[indexInteger].projectId;
                this.notificationWeekList_line5[i].title = this.notificationWeekList_line5[indexInteger].title;
                this.notificationWeekList_line5[i].isLoading = false;

            } else {
                if(this.notificationWeekList_line5[i] && this.notificationWeekList_line5[i].idSalesforce) { 

                const updatedNotification = await this.saveNotification(this.notificationWeekList_line5[i]);
                this.notificationWeekList_line5[i].idSalesforce = updatedNotification.idSalesforce;
            }
            
            this.notificationWeekList_line5[i].isLoading = false;
        }

          }
        }
    }
}


async handleCloneNotificationToRight(event) {
    let notification;
    let notificationLine2;
    let index2;
  
    var coluna = event.currentTarget.dataset.id.substring(0, 1);
    var linha = event.currentTarget.dataset.id.substring(1, 3);
  
    
    switch (coluna) {
      case 'A':
        notification = this.cloneObj(this.notificationWeekList_line1.find(element => element.id === (coluna + linha)));
        
        index2 = 'B' + linha;
        notificationLine2 = this.notificationWeekList_line2.find(element => element.id === index2);
        notificationLine2.profileId = notification.profileId;
        notificationLine2.projectId = notification.projectId;
        notificationLine2.title = notification.title;
  
        break;
      case 'B':
        notification = this.cloneObj(this.notificationWeekList_line2.find(element => element.id === (coluna + linha)));
        index2 = 'C' + linha;
        notificationLine2 = this.notificationWeekList_line3.find(element => element.id === index2);
        notificationLine2.profileId = notification.profileId;
        notificationLine2.projectId = notification.projectId;
        notificationLine2.title = notification.title; // Define um valor padrão se o título estiver ausente
        
        
        break;
      case 'C':
        notification = this.cloneObj(this.notificationWeekList_line3.find(element => element.id === (coluna + linha)));
        index2 = 'D' + linha;
        notificationLine2 = this.notificationWeekList_line4.find(element => element.id === index2);
        notificationLine2.profileId = notification.profileId;
        notificationLine2.projectId = notification.projectId;
        notificationLine2.title = notification.title; // Define um valor padrão se o título estiver ausente
  
        
        break;
      case 'D':
        notification = this.cloneObj(this.notificationWeekList_line4.find(element => element.id === (coluna + linha)));
        index2 = 'E' + linha;
        notificationLine2 = this.notificationWeekList_line5.find(element => element.id === index2);
        notificationLine2.profileId = notification.profileId;
        notificationLine2.projectId = notification.projectId;
        notificationLine2.title = notification.title; // Define um valor padrão se o título estiver ausente
  
        break;
      default:
        break;
    }


    // Verifica se a notificação já está salva no Salesforce
    if (notificationLine2 && notificationLine2.idSalesforce) {
    // Se a notificação já está salva, atualiza seus valores e a salva novamente
    // Atualiza os valores da notificação existente com os valores da notificação original
    notificationLine2.profileId = notification.profileId;
    notificationLine2.projectId = notification.projectId;
    notificationLine2.title = notification.title;
    
    try {
        // Salva a notificação atualizada no Salesforce
        const updatedNotification = await this.saveNotification(notificationLine2);
        // Atualiza o idSalesforce da notificação com o valor retornado pela operação de atualização
        notificationLine2.idSalesforce = updatedNotification.idSalesforce;
    } catch (error) {
        // Se ocorrer um erro ao salvar a notificação, exibe uma mensagem de erro
        console.error('Erro ao atualizar a notificação:', error);
    }
    } else {
    // Se a notificação ainda não está salva, clona e salva a notificação
    try {
        // Verifica se tanto a notificação original quanto a notificação de destino estão presentes
        if (notification && notificationLine2) {
            // Clona a notificação original para a notificação de destino
            notificationLine2 = this.cloneObj(notification);
            
            // Salva a notificação de destino no Salesforce
            const updatedNotification = await this.saveNotification(notificationLine2);
            // Atualiza o idSalesforce da notificação de destino com o valor retornado pela operação de salvamento
            notificationLine2.idSalesforce = updatedNotification.idSalesforce;
        }
    } catch (error) {
        // Se ocorrer um erro ao clonar ou salvar a notificação, exibe uma mensagem de erro
        console.error('Erro ao clonar ou salvar a notificação:', error);
    }
}

// Define o estado de carregamento como false após a clonagem ou atualização da notificação
if (notificationLine2) {
    notificationLine2.isLoading = false;
}

// Atualiza a interface do usuário após a alteração da notificação

}

async handleAllCloneNotificationToRight(event) {
    let notification;
    let notificationLine2;
    let notificationLine3;
    let notificationLine4;
    let notificationLine5;
    let index2;


    var coluna = event.currentTarget.dataset.id.substring(0,1);
    var linha = event.currentTarget.dataset.id.substring(1,3);

    switch(coluna) {

    case 'A':
        notification = this.cloneObj(this.notificationWeekList_line1.find(element => element.id === (coluna + linha)));
        index2 = 'B' + linha;
        notificationLine2 = this.notificationWeekList_line2.find(element => element.id === index2);
        notificationLine2.profileId = notification.profileId;
        notificationLine2.projectId = notification.projectId;
        notificationLine2.title = notification.title;


        index2 = 'C' + linha;
        notificationLine3 = this.notificationWeekList_line3.find(element => element.id === index2);
        notificationLine3.profileId = notification.profileId;
        notificationLine3.projectId = notification.projectId;
        notificationLine3.title = notification.title;


        index2 = 'D' + linha;
        notificationLine4 = this.notificationWeekList_line4.find(element => element.id === index2);
        notificationLine4.profileId = notification.profileId;
        notificationLine4.projectId = notification.projectId;
        notificationLine4.title = notification.title;
        

        index2 = 'E' + linha;
        notificationLine5 = this.notificationWeekList_line5.find(element => element.id === index2);
        notificationLine5.profileId = notification.profileId;
        notificationLine5.projectId = notification.projectId;
        notificationLine5.title = notification.title;


        try {

            if(notificationLine2 && notificationLine2.idSalesforce || notificationLine3 && notificationLine3.idSalesforce || notificationLine4 && notificationLine4.idSalesforce || notificationLine5 && notificationLine5.idSalesforce) {
            const updatedNotification = await this.saveNotification(notificationLine2);
            notificationLine2.idSalesforce = updatedNotification.idSalesforce;
            const updatedNotification2 = await this.saveNotification(notificationLine3);
            notificationLine3.idSalesforce = updatedNotification2.idSalesforce;
            const updatedNotification3 = await this.saveNotification(notificationLine4);
            notificationLine4.idSalesforce = updatedNotification3.idSalesforce;
            const updatedNotification4 = await this.saveNotification(notificationLine5);
            notificationLine5.idSalesforce = updatedNotification4.idSalesforce;
        }
        } catch (error) {
            
            console.error('Erro ao salvar a notificação:', error);
        }

        notificationLine2.isLoading = false;
        notificationLine3.isLoading = false;
        notificationLine4.isLoading = false;
        notificationLine5.isLoading = false;
        
    break;
    case 'B':
        notification = this.cloneObj(this.notificationWeekList_line2.find(element => element.id === (coluna + linha)));

        index2 = 'C' + linha;
        notificationLine3 = this.notificationWeekList_line3.find(element => element.id === index2);
        notificationLine3.profileId = notification.profileId;
        notificationLine3.projectId = notification.projectId;
        notificationLine3.title = notification.title;


        index2 = 'D' + linha;
        notificationLine4 = this.notificationWeekList_line4.find(element => element.id === index2);
        notificationLine4.profileId = notification.profileId;
        notificationLine4.projectId = notification.projectId;
        notificationLine4.title = notification.title;


        index2 = 'E' + linha;
        notificationLine5 = this.notificationWeekList_line5.find(element => element.id === index2);
        notificationLine5.profileId = notification.profileId;
        notificationLine5.projectId = notification.projectId;
        notificationLine5.title = notification.title;

        try {

            if(notificationLine3 && notificationLine3.idSalesforce || notificationLine4 && notificationLine4.idSalesforce || notificationLine5 && notificationLine5.idSalesforce) {
            const updatedNotification2 = await this.saveNotification(notificationLine3);
            notificationLine3.idSalesforce = updatedNotification2.idSalesforce;
            const updatedNotification3 = await this.saveNotification(notificationLine4);
            notificationLine4.idSalesforce = updatedNotification3.idSalesforce;
            const updatedNotification4 = await this.saveNotification(notificationLine5);
            notificationLine5.idSalesforce = updatedNotification4.idSalesforce;
        }
        } catch (error) {
            
            console.error('Erro ao salvar a notificação:', error);
        }

        notificationLine3.isLoading = false;
        notificationLine4.isLoading = false;
        notificationLine5.isLoading = false
    break;
    case 'C':
        notification = this.cloneObj(this.notificationWeekList_line3.find(element => element.id === (coluna + linha)));
        index2 = 'D' + linha;
        notificationLine4 = this.notificationWeekList_line4.find(element => element.id === index2);
        notificationLine4.profileId = notification.profileId;
        notificationLine4.projectId = notification.projectId;
        notificationLine4.title = notification.title;


        index2 = 'E' + linha;
        notificationLine5 = this.notificationWeekList_line5.find(element => element.id === index2);
        notificationLine5.profileId = notification.profileId;
        notificationLine5.projectId = notification.projectId;
        notificationLine5.title = notification.title;

        try {

            if(notificationLine4 && notificationLine4.idSalesforce || notificationLine5 && notificationLine5.idSalesforce) {
            const updatedNotification3 = await this.saveNotification(notificationLine4);
            notificationLine4.idSalesforce = updatedNotification3.idSalesforce;
            const updatedNotification4 = await this.saveNotification(notificationLine5);
            notificationLine5.idSalesforce = updatedNotification4.idSalesforce;
        }
        } catch (error) {
            
            console.error('Erro ao salvar a notificação:', error);
        }

        notificationLine4.isLoading = false;
        notificationLine5.isLoading = false
    break;
    case 'D':
        notification = this.cloneObj(this.notificationWeekList_line4.find(element => element.id === (coluna + linha)));
        index2 = 'E' + linha;
        notificationLine5 = this.notificationWeekList_line5.find(element => element.id === index2);
        notificationLine5.profileId = notification.profileId;
        notificationLine5.projectId = notification.projectId;
        notificationLine5.title = notification.title;

        try {

            if(notificationLine5 && notificationLine5.idSalesforce) {
            const updatedNotification4 = await this.saveNotification(notificationLine5);
            notificationLine5.idSalesforce = updatedNotification4.idSalesforce;
        }
        } catch (error) {
            
            console.error('Erro ao salvar a notificação:', error);
        }

        notificationLine5.isLoading = false;

    break;
    default:
        break;
        }

        
    }
     
    clearProject(event) {
        
        const { indexId } = event.detail;
        let notification;
       

        switch (indexId.substring(0,1)){
            case "A":
                notification = this.notificationWeekList_line1.find(not => not.id === indexId);
                // this.projectEditFooter(indexId)
              
                break;
            case "B":
                notification = this.notificationWeekList_line2.find(not => not.id === indexId);
                // this.projectEditFooter(indexId)

                break;
            case "C":
                notification = this.notificationWeekList_line3.find(not => not.id === indexId);
                // this.projectEditFooter(indexId)

                break;
            case "D":
                notification = this.notificationWeekList_line4.find(not => not.id === indexId);
                // this.projectEditFooter(indexId)

                break;
            case "E":
                notification = this.notificationWeekList_line5.find(not => not.id === indexId);
                // this.projectEditFooter(indexId)
 
                break;
        }
        notification.profileId = null;
        notification.projectId = null;
     }

     changeProfile(event) {
        const { record } = event.detail;
	    const { indexId } = event.detail;

     }

    async changeProject(event) {
	    const { record } = event.detail;
	    const { indexId } = event.detail;


        let notification;

        switch (indexId.substring(0,1)){
            case "A":
              
                notification = this.notificationWeekList_line1.find(not => not.id === indexId);
                break;
            case "B":
           
                notification = this.notificationWeekList_line2.find(not => not.id === indexId);

                break;
            case "C":
            
                notification = this.notificationWeekList_line3.find(not => not.id === indexId);
                break;
            case "D":
     
                notification = this.notificationWeekList_line4.find(not => not.id === indexId);
                break;
            case "E":
           
                notification = this.notificationWeekList_line5.find(not => not.id === indexId);
                break;
        }

		notification.projectId = record.Projeto__c;

		if(notification.projectId != null) {
            notification.profileId = record.Id;
        }
        notification.idSalesforce = this.cloneObj(await this.saveNotification(notification)).idSalesforce;
        notification.isLoading = false;
    }

    cloneObj(value) {
        return value;
    }
    
     async onChangeTitle(event) {
        let value = event.target.value;

        let notificationCurrentId = event.currentTarget.dataset.titleId;
        let notification;
        var coluna = notificationCurrentId.substring(0,1);

        switch(coluna) {
            case 'A':
               notification = this.notificationWeekList_line1.find(notification => notification.id == notificationCurrentId);
               notification.title = value;
            break;
            case 'B':
               notification = this.notificationWeekList_line2.find(notification => notification.id == notificationCurrentId);
               notification.title = value;
            break;
            case 'C':
               notification = this.notificationWeekList_line3.find(notification => notification.id == notificationCurrentId);
               notification.title = value;
            break;
            case 'D':
               notification = this.notificationWeekList_line4.find(notification => notification.id == notificationCurrentId);
               notification.title = value;
            break;
            case 'E':
               notification = this.notificationWeekList_line5.find(notification => notification.id == notificationCurrentId);
               notification.title = value;
            break;
            default:
               break;   

    }
       
    }
    

    async handleClickPreviousWeek(event) {     
       this.offSetWeek = this.offSetWeek - 1;
       this.isLoading = true;
       this.connectedCallback()
       this.notificationHeader = await getWeekBody({ offSetWeek: this.offSetWeek });
       this.isLoading = false;
    }

    async handleClickNextWeek(event) {
       this.offSetWeek = this.offSetWeek + 1;
       this.isLoading = true;
       this.connectedCallback()
       this.notificationHeader = await getWeekBody({offSetWeek: this.offSetWeek});
       this.isLoading = false;
    }
    
   async handleFocusOutTitle(event) {
       let notificationCurrentId = event.currentTarget.dataset.titleId; 
       let notification;
       var coluna = notificationCurrentId.substring(0,1);
    //    let formValidation = document.getElementById("reloadForm");
    //    formValidation.value = "";
    
    switch (coluna) {
        case 'A':
            notification = this.notificationWeekList_line1.find(notification => notification.id == notificationCurrentId);
            notification.idSalesforce = this.cloneObj(await this.saveNotification(notification)).idSalesforce;
            
            notification.isLoading = false;
               return true;
           case 'B':
               notification = this.notificationWeekList_line2.find(notification => notification.id == notificationCurrentId);
               notification.idSalesforce = this.cloneObj(await this.saveNotification(notification)).idSalesforce;
               
               notification.isLoading = false;
               return true;
           case 'C':
               notification = this.notificationWeekList_line3.find(notification => notification.id == notificationCurrentId);
               notification.idSalesforce = this.cloneObj(await this.saveNotification(notification)).idSalesforce;
               
               notification.isLoading = false;
               return true;
           case 'D':
               notification = this.notificationWeekList_line4.find(notification => notification.id == notificationCurrentId);
               notification.idSalesforce = this.cloneObj(await this.saveNotification(notification)).idSalesforce;
              
               notification.isLoading = false;
               return true;

           case 'E':
               notification = this.notificationWeekList_line5.find(notification => notification.id == notificationCurrentId);
               notification.idSalesforce = this.cloneObj(await this.saveNotification(notification)).idSalesforce;
             
               notification.isLoading = false;
               return true;
           default:
               return false;         
 }   
    }

     async saveNotification(notification) {
        if(notification.profileId != null && notification.profileId != null && (notification.title != null && notification.title != '') ) {
            notification.isLoading = true;


                this.changeFooterBackground(notification);
            
            return await upsertNotification({notificationString: JSON.stringify(notification)});
        } else {
            notification.isLoading = false;
            return notification;
        }
     }
     async changeFooterBackground(event){

        let notificationCurrentId = event.id;
        let notification;
        var coluna = notificationCurrentId.substring(0,1);
     
     switch (coluna) {
         case 'A':
             notification = this.notificationWeekList_line1.find(notification => notification.id == notificationCurrentId);
             const card = this.template.querySelector(`.${notificationCurrentId}`);
             card.style.backgroundColor = '#3BA755'
                return true;
            case 'B':
                notification = this.notificationWeekList_line2.find(notification => notification.id == notificationCurrentId);
                const card02 = this.template.querySelector(`.${notificationCurrentId}`);
             card02.style.backgroundColor = '#3BA755'
                return true;
            case 'C':
                notification = this.notificationWeekList_line3.find(notification => notification.id == notificationCurrentId);
                const card03 = this.template.querySelector(`.${notificationCurrentId}`);
             card03.style.backgroundColor = '#3BA755'
                return true;
            case 'D':
                notification = this.notificationWeekList_line4.find(notification => notification.id == notificationCurrentId);
                const card04 = this.template.querySelector(`.${notificationCurrentId}`);
             card04.style.backgroundColor = '#3BA755'
                return true;
 
            case 'E':
                notification = this.notificationWeekList_line5.find(notification => notification.id == notificationCurrentId);
                const card05 = this.template.querySelector(`.${notificationCurrentId}`);
             card05.style.backgroundColor = '#3BA755'
                return true;
            default:
                return false;         
  }   
     }
}