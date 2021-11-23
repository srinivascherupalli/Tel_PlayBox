import { LightningElement, api } from 'lwc';

export default class PreChatSection extends LightningElement {
    @api sectionLabel;
    @api sectionValue;
}